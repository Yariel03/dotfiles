import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

ShellRoot {
    id: root

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property var modelData
            screen: modelData

            color: "transparent"
            exclusiveZone: 0
            WlrLayershell.namespace: "stats-widget"
            // Capa Bottom: queda en el fondo de escritorio sobre el wallpaper y debajo de las ventanas
            WlrLayershell.layer: WlrLayer.Bottom
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            // Posicionado en el cuadrante superior derecho del escritorio
            anchors {
                top: true
                right: true
            }

            // Margen para no colisionar con ashell superior y dejar aire
            margins {
                top: 70
                right: 35
            }

            implicitWidth: widget.width + 16
            implicitHeight: widget.height + 16

            StatsWidget {
                id: widget
                anchors.centerIn: parent
                scaleFactor: (win.screen && win.screen.height < 1080) ? 0.88 : 1.0
            }
        }
    }
}
