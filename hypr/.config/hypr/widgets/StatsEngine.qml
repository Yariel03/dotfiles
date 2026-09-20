import QtQuick
import Quickshell
import Quickshell.Io

Item {
    id: engine

    property bool active: true
    readonly property int pollIntervalMs: 1500

    // Métricas de CPU
    property real cpu: 0.15
    property var cpuHistory: [0.1, 0.15, 0.12, 0.2, 0.18, 0.14, 0.22, 0.19, 0.16, 0.25, 0.18, 0.15]
    property real cpuTemp: 45.0

    // Métricas de Memoria RAM
    property real memUsedGiB: 8.0
    property real memTotalGiB: 32.0
    property real memPct: 0.25

    // Métricas de GPU
    property real gpuPct: 10.0
    property real gpuPowerW: 20.0
    property real gpuTemp: 50.0

    // Métricas de Red
    property real downBps: 0
    property real upBps: 0
    property var netDownHist: [0, 1024, 2048, 512, 1024, 4096, 2048, 1024]
    property var netUpHist: [0, 512, 1024, 256, 512, 1024, 512, 256]
    property real netMax: 10240

    // Almacenamiento
    property real diskUsedGiB: 100.0
    property real diskTotalGiB: 950.0
    property real diskPct: 0.10

    // Estado interno para cálculos de delta
    property real _prevIdle: 0
    property real _prevTotal: 0
    property real _prevRx: 0
    property real _prevTx: 0
    property bool _hasSample: false

    function formatBytes(bps) {
        var b = Math.max(0, bps || 0);
        if (b < 1024) return b.toFixed(0) + " B/s";
        if (b < 1048576) return (b / 1024).toFixed(1) + " KiB/s";
        if (b < 1073741824) return (b / 1048576).toFixed(1) + " MiB/s";
        return (b / 1073741824).toFixed(2) + " GiB/s";
    }

    Process {
        id: proc
        command: ["python3", Quickshell.env("HOME") + "/.config/hypr/widgets/read_stats.py"]
        stdout: StdioCollector {
            onStreamFinished: {
                if (!this.text || this.text.trim().length === 0) return;
                try {
                    var d = JSON.parse(this.text.trim());

                    // Cálculo de CPU
                    if (engine._prevTotal > 0 && d.total > engine._prevTotal) {
                        var dt = d.total - engine._prevTotal;
                        var di = d.idle - engine._prevIdle;
                        var u = Math.max(0, Math.min(1, 1 - (di / dt)));
                        engine.cpu = u;

                        var h = engine.cpuHistory.slice();
                        h.push(u);
                        while (h.length > 36) h.shift();
                        engine.cpuHistory = h;
                    }
                    engine._prevTotal = d.total;
                    engine._prevIdle = d.idle;

                    // Cálculo de Red
                    if (engine._hasSample) {
                        var rxDiff = Math.max(0, d.rx - engine._prevRx);
                        var txDiff = Math.max(0, d.tx - engine._prevTx);
                        var intervalSec = engine.pollIntervalMs / 1000.0;

                        engine.downBps = rxDiff / intervalSec;
                        engine.upBps = txDiff / intervalSec;

                        var dh = engine.netDownHist.slice();
                        dh.push(engine.downBps);
                        while (dh.length > 32) dh.shift();
                        engine.netDownHist = dh;

                        var uh = engine.netUpHist.slice();
                        uh.push(engine.upBps);
                        while (uh.length > 32) uh.shift();
                        engine.netUpHist = uh;

                        var m = 10240; // Mínimo 10 KiB/s de escala
                        for (var i = 0; i < dh.length; i++) if (dh[i] > m) m = dh[i];
                        for (var j = 0; j < uh.length; j++) if (uh[j] > m) m = uh[j];
                        engine.netMax = m;
                    }
                    engine._prevRx = d.rx;
                    engine._prevTx = d.tx;
                    engine._hasSample = true;

                    // Memoria
                    engine.memTotalGiB = d.mem_total_gib;
                    engine.memUsedGiB = d.mem_used_gib;
                    if (d.mem_total_gib > 0) {
                        engine.memPct = Math.min(1, d.mem_used_gib / d.mem_total_gib);
                    }

                    // GPU
                    engine.gpuPct = d.gpu_pct;
                    engine.gpuPowerW = d.gpu_pwr;
                    engine.gpuTemp = d.gpu_temp;

                    // CPU Temp
                    engine.cpuTemp = d.cpu_temp;

                    // Disco
                    engine.diskTotalGiB = d.disk_total_gib;
                    engine.diskUsedGiB = d.disk_used_gib;
                    if (d.disk_total_gib > 0) {
                        engine.diskPct = Math.min(1, d.disk_used_gib / d.disk_total_gib);
                    }
                } catch (e) {
                    // Ignorar errores transitorios de lectura
                }
            }
        }
    }

    Timer {
        id: timer
        interval: engine.pollIntervalMs
        repeat: true
        running: engine.active
        triggeredOnStart: true
        onTriggered: {
            if (!proc.running) {
                proc.running = true;
            }
        }
    }
}
