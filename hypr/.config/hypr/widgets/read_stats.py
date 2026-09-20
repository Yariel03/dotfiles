#!/usr/bin/env python3
# Telemetría de hardware ligera para el widget de estadísticas (Quickshell Stats)
import os, json, glob

def get_stats():
    # 1. Red (RX / TX acumulado en bytes)
    rx, tx = 0, 0
    try:
        with open("/proc/net/dev") as f:
            for line in f:
                if ":" in line:
                    iface, data = line.split(":", 1)
                    if iface.strip() != "lo":
                        vals = data.split()
                        rx += int(vals[0])
                        tx += int(vals[8])
    except Exception:
        pass

    # 2. CPU jiffies (idle y total)
    idle, total = 0, 0
    try:
        with open("/proc/stat") as f:
            fields = [float(x) for x in f.readline().split()[1:]]
            idle = fields[3] + fields[4]
            total = sum(fields)
    except Exception:
        pass

    # 3. Memoria RAM
    mem_total_gib, mem_used_gib = 0.0, 0.0
    try:
        mem = {}
        with open("/proc/meminfo") as f:
            for line in f:
                parts = line.split(":")
                if parts[0] in ("MemTotal", "MemAvailable"):
                    mem[parts[0]] = int(parts[1].split()[0])
        tot = mem.get("MemTotal", 0)
        avail = mem.get("MemAvailable", 0)
        mem_total_gib = round(tot / 1048576.0, 1)
        mem_used_gib = round((tot - avail) / 1048576.0, 1)
    except Exception:
        pass

    # 4. GPU (AMD Radeon o Intel)
    gpu_pct, gpu_pwr, gpu_temp = 0, 0.0, 0.0
    for card in glob.glob("/sys/class/drm/card[0-9]"):
        try:
            with open(os.path.join(card, "device/gpu_busy_percent")) as f:
                gpu_pct = int(f.read().strip())
        except Exception:
            pass

        for hw in glob.glob(os.path.join(card, "device/hwmon/hwmon*")):
            try:
                with open(os.path.join(hw, "power1_average")) as f:
                    gpu_pwr = round(int(f.read().strip()) / 1000000.0, 1)
            except Exception:
                try:
                    with open(os.path.join(hw, "power1_input")) as f:
                        gpu_pwr = round(int(f.read().strip()) / 1000000.0, 1)
                except Exception:
                    pass
            try:
                with open(os.path.join(hw, "temp1_input")) as f:
                    gpu_temp = round(int(f.read().strip()) / 1000.0, 1)
            except Exception:
                pass
        if gpu_pct > 0 or gpu_temp > 0:
            break

    # 5. Temperatura CPU
    cpu_temp = 0.0
    for hw in glob.glob("/sys/class/hwmon/hwmon*"):
        try:
            with open(os.path.join(hw, "name")) as f:
                name = f.read().strip()
            if name in ("coretemp", "k10temp", "zenpower", "cpu_thermal"):
                with open(os.path.join(hw, "temp1_input")) as f:
                    cpu_temp = round(int(f.read().strip()) / 1000.0, 1)
                    break
        except Exception:
            pass

    # 6. Disco raíz /
    disk_total_gib, disk_used_gib = 0.0, 0.0
    try:
        st = os.statvfs("/")
        disk_total_gib = round((st.f_blocks * st.f_frsize) / (1024**3), 1)
        disk_used_gib = round(((st.f_blocks - st.f_bfree) * st.f_frsize) / (1024**3), 1)
    except Exception:
        pass

    return {
        "idle": idle,
        "total": total,
        "mem_total_gib": mem_total_gib,
        "mem_used_gib": mem_used_gib,
        "rx": rx,
        "tx": tx,
        "gpu_pct": gpu_pct,
        "gpu_pwr": gpu_pwr,
        "gpu_temp": gpu_temp,
        "cpu_temp": cpu_temp,
        "disk_total_gib": disk_total_gib,
        "disk_used_gib": disk_used_gib
    }

if __name__ == "__main__":
    print(json.dumps(get_stats()))
