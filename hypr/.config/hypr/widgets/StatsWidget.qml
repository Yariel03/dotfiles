import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property alias engine: statsEngine
    property real scaleFactor: 1.0

    width: 380 * scaleFactor
    height: 640 * scaleFactor
    radius: 16
    color: Qt.rgba(0.10, 0.11, 0.15, 0.90) // Fondo glass Tokyo Night traslúcido
    border.width: 1
    border.color: Qt.rgba(122/255, 162/255, 247/255, 0.35) // Borde con halo azul eléctrico
    clip: true

    StatsEngine {
        id: statsEngine
        active: root.visible
    }

    // Sombra de profundidad Tokyo Night
    Rectangle {
        z: -1
        x: 6
        y: 6
        width: root.width
        height: root.height
        radius: root.radius
        color: Qt.rgba(0.04, 0.05, 0.08, 0.80)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20 * root.scaleFactor
        spacing: 16 * root.scaleFactor

        // 1. CABECERA CON SELLO EN TEMA TOKYO NIGHT (ARCH LINUX LOGO NERD FONT)
        RowLayout {
            Layout.fillWidth: true
            spacing: 12 * root.scaleFactor

            Rectangle {
                width: 34 * root.scaleFactor
                height: 34 * root.scaleFactor
                radius: 8
                color: "#7aa2f7" // Azul Tokio vibrante

                Text {
                    anchors.centerIn: parent
                    text: "\uf303" //  Arch Linux logo en Nerd Font
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 20 * root.scaleFactor
                    color: "#16161e"
                }
            }

            Column {
                Layout.fillWidth: true
                spacing: 2

                Text {
                    text: "SYSTEM STATUS"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14 * root.scaleFactor
                    font.bold: true
                    font.letterSpacing: 2
                    color: "#c0caf5"
                }

                Text {
                    text: "LIVE TELEMETRY // TOKYO NIGHT"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 10 * root.scaleFactor
                    color: "#7dcfff"
                }
            }
        }

        // 2. GRÁFICO DE ÁREA DE CPU EN TIEMPO REAL (AZUL / CIAN)
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 70 * root.scaleFactor
            radius: 8
            color: "#16161e"
            border.width: 1
            border.color: Qt.rgba(122/255, 162/255, 247/255, 0.22)
            clip: true

            Canvas {
                id: cpuCanvas
                anchors.fill: parent
                anchors.margins: 4

                property var history: statsEngine.cpuHistory
                onHistoryChanged: requestPaint()

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    var pts = cpuCanvas.history || [];
                    var len = pts.length;
                    if (len < 2) return;

                    var w = width;
                    var h = height;
                    var dx = w / (len - 1);

                    function getY(v) {
                        return h - (Math.max(0, Math.min(1, v)) * (h - 6));
                    }

                    ctx.beginPath();
                    ctx.moveTo(0, h);
                    for (var i = 0; i < len; i++) {
                        ctx.lineTo(i * dx, getY(pts[i]));
                    }
                    ctx.lineTo(w, h);
                    ctx.closePath();

                    var grad = ctx.createLinearGradient(0, 0, 0, h);
                    grad.addColorStop(0, "rgba(122, 162, 247, 0.40)");
                    grad.addColorStop(1, "rgba(122, 162, 247, 0.04)");
                    ctx.fillStyle = grad;
                    ctx.fill();

                    ctx.beginPath();
                    for (var j = 0; j < len; j++) {
                        var cy = getY(pts[j]);
                        if (j === 0) ctx.moveTo(0, cy);
                        else ctx.lineTo(j * dx, cy);
                    }
                    ctx.lineWidth = 2;
                    ctx.strokeStyle = "rgba(122, 162, 247, 0.95)";
                    ctx.stroke();
                }
            }
        }

        // 3. FILAS DE MÉTRICAS PRINCIPALES CON ICONOS NERD FONT
        Column {
            Layout.fillWidth: true
            spacing: 6 * root.scaleFactor

            component MetricRow: RowLayout {
                id: mRow
                property string icon: ""
                property string label: ""
                property string value: ""
                property color iconColor: "#7aa2f7"
                width: parent.width
                spacing: 8 * root.scaleFactor

                Text {
                    text: mRow.icon
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 14 * root.scaleFactor
                    color: mRow.iconColor
                    Layout.preferredWidth: 18 * root.scaleFactor
                    horizontalAlignment: Text.AlignHCenter
                }

                Text {
                    Layout.fillWidth: true
                    text: mRow.label
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12 * root.scaleFactor
                    color: "#a9b1d6"
                }

                Text {
                    text: mRow.value
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 12 * root.scaleFactor
                    font.bold: true
                    color: "#c0caf5"
                }
            }

            MetricRow {
                icon: "\uf2db" //  CPU chip
                label: "CPU Usage"
                value: (statsEngine.cpu * 100).toFixed(1) + "%"
                iconColor: "#7aa2f7" // Azul eléctrico
            }

            MetricRow {
                icon: "\uf108" //  GPU / Pantalla
                label: "GPU Load"
                value: statsEngine.gpuPct.toFixed(0) + "%"
                iconColor: "#bb9af7" // Púrpura Tokio
            }

            MetricRow {
                icon: "\uf538" //  RAM chip
                label: "Memory RAM"
                value: statsEngine.memUsedGiB.toFixed(1) + " / " + statsEngine.memTotalGiB.toFixed(0) + " GiB"
                iconColor: "#7dcfff" // Cian Tokio
            }

            MetricRow {
                icon: "\uf0e7" //  Rayo de potencia
                label: "GPU Power"
                value: statsEngine.gpuPowerW.toFixed(1) + " W"
                iconColor: "#73daca" // Menta Tokio
            }
        }

        // Separador fino
        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Qt.rgba(1, 1, 1, 0.08)
        }

        // 4. GRÁFICO DUAL DE RED (DOWN / UP - CIAN Y PÚRPURA CON ICONOS)
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6 * root.scaleFactor

            RowLayout {
                Layout.fillWidth: true
                spacing: 6 * root.scaleFactor

                Text {
                    text: "\uf012" //  Señal / Red
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11 * root.scaleFactor
                    color: "#7dcfff"
                }

                Text {
                    text: "NETWORK THROUGHPUT"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 10 * root.scaleFactor
                    font.bold: true
                    font.letterSpacing: 1
                    color: "#787c99"
                }
                Item { Layout.fillWidth: true }
                Text {
                    text: "Peak: " + statsEngine.formatBytes(statsEngine.netMax)
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 9 * root.scaleFactor
                    color: "#565f89"
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 56 * root.scaleFactor
                radius: 8
                color: "#16161e"
                border.width: 1
                border.color: Qt.rgba(125/255, 207/255, 255/255, 0.18)
                clip: true

                Canvas {
                    id: netCanvas
                    anchors.fill: parent
                    anchors.margins: 4

                    property var dn: statsEngine.netDownHist
                    property var up: statsEngine.netUpHist
                    onDnChanged: requestPaint()
                    onUpChanged: requestPaint()

                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();
                        var peak = statsEngine.netMax > 0 ? statsEngine.netMax : 10240;

                        function drawLine(hist, strokeColor) {
                            if (!hist || hist.length < 2) return;
                            var w = width;
                            var h = height;
                            var len = hist.length;
                            var dx = w / (len - 1);

                            ctx.beginPath();
                            for (var i = 0; i < len; i++) {
                                var val = Math.max(0, Math.min(1, hist[i] / peak));
                                var cy = h - (val * (h - 6));
                                if (i === 0) ctx.moveTo(0, cy);
                                else ctx.lineTo(i * dx, cy);
                            }
                            ctx.lineWidth = 1.6;
                            ctx.strokeStyle = strokeColor;
                            ctx.stroke();
                        }

                        drawLine(netCanvas.dn, "rgba(125, 207, 255, 0.95)");
                        drawLine(netCanvas.up, "rgba(187, 154, 247, 0.95)");
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 6 * root.scaleFactor

                Text {
                    text: "\uf063" //  Flecha descarga
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11 * root.scaleFactor
                    color: "#7dcfff"
                }
                Text {
                    text: "DN: " + statsEngine.formatBytes(statsEngine.downBps)
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 10 * root.scaleFactor
                    color: "#7dcfff"
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: "\uf062" //  Flecha subida
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11 * root.scaleFactor
                    color: "#bb9af7"
                }
                Text {
                    text: "UP: " + statsEngine.formatBytes(statsEngine.upBps)
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 10 * root.scaleFactor
                    color: "#bb9af7"
                }
            }
        }

        // 5. ALMACENAMIENTO (DISCO RAÍZ CON ICONO DISCO)
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6 * root.scaleFactor

            RowLayout {
                Layout.fillWidth: true
                spacing: 6 * root.scaleFactor

                Text {
                    text: "\uf0a0" //  Disco duro
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 11 * root.scaleFactor
                    color: "#9ece6a"
                }

                Text {
                    text: "STORAGE (/)"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 10 * root.scaleFactor
                    font.bold: true
                    font.letterSpacing: 1
                    color: "#787c99"
                }

                Item { Layout.fillWidth: true }

                Text {
                    text: statsEngine.diskUsedGiB.toFixed(0) + " / " + statsEngine.diskTotalGiB.toFixed(0) + " GiB (" + (statsEngine.diskPct * 100).toFixed(0) + "%)"
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 10 * root.scaleFactor
                    color: "#c0caf5"
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 8 * root.scaleFactor
                radius: 4
                color: "#16161e"

                Rectangle {
                    width: parent.width * statsEngine.diskPct
                    height: parent.height
                    radius: 4
                    color: "#9ece6a" // Verde Tokyo Night
                }
            }
        }

        // 6. TEMPERATURAS Y HARDWARE CON ICONOS DE TERMÓMETRO
        RowLayout {
            Layout.fillWidth: true
            spacing: 12 * root.scaleFactor

            Rectangle {
                Layout.fillWidth: true
                height: 44 * root.scaleFactor
                radius: 8
                color: "#16161e"
                border.width: 1
                border.color: Qt.rgba(122/255, 162/255, 247/255, 0.22)

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8 * root.scaleFactor

                    Text {
                        text: "\uf2c9" //  Termómetro
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16 * root.scaleFactor
                        color: "#7aa2f7"
                    }

                    Column {
                        spacing: 1
                        Text { text: "CPU TEMP"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 9 * root.scaleFactor; color: "#787c99" }
                        Text { text: statsEngine.cpuTemp.toFixed(1) + " °C"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12 * root.scaleFactor; font.bold: true; color: "#7aa2f7" }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 44 * root.scaleFactor
                radius: 8
                color: "#16161e"
                border.width: 1
                border.color: Qt.rgba(187/255, 154/255, 247/255, 0.25)

                RowLayout {
                    anchors.centerIn: parent
                    spacing: 8 * root.scaleFactor

                    Text {
                        text: "\uf2c9" //  Termómetro
                        font.family: "JetBrainsMono Nerd Font"
                        font.pixelSize: 16 * root.scaleFactor
                        color: "#bb9af7"
                    }

                    Column {
                        spacing: 1
                        Text { text: "GPU TEMP"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 9 * root.scaleFactor; color: "#787c99" }
                        Text { text: statsEngine.gpuTemp.toFixed(1) + " °C"; font.family: "JetBrainsMono Nerd Font"; font.pixelSize: 12 * root.scaleFactor; font.bold: true; color: "#bb9af7" }
                    }
                }
            }
        }
    }
}
