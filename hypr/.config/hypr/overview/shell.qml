import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets

ShellRoot {
    id: root

    // Instancia del tema visual (Tokyo Night Luminous o Ryoku Vermillion)
    Theme {
        id: theme
        preset: "tokyo-night"
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property var modelData
            screen: modelData

            color: "transparent"
            exclusiveZone: 0
            WlrLayershell.namespace: "overview"
            WlrLayershell.layer: WlrLayer.Overlay
            anchors { top: true; bottom: true; left: true; right: true }

            readonly property bool isFocused: {
                var fm = Hyprland.focusedMonitor;
                return fm && fm.name ? (modelData ? fm.name === modelData.name : false) : true;
            }

            WlrLayershell.keyboardFocus: isFocused ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            // Geometría del monitor
            readonly property var monObj: {
                var ms = Hyprland.monitors.values;
                for (var i = 0; i < ms.length; i++) {
                    if (ms[i] && ms[i].name === modelData.name)
                        return ms[i].lastIpcObject;
                }
                return null;
            }
            readonly property real monScale: (monObj && monObj.scale > 0) ? monObj.scale : 1
            readonly property real monLW: (monObj && monObj.width > 0) ? monObj.width / monScale : 1920
            readonly property real monLH: (monObj && monObj.height > 0) ? monObj.height / monScale : 1080
            readonly property real monX: (monObj && typeof monObj.x === "number") ? monObj.x : 0
            readonly property real monY: (monObj && typeof monObj.y === "number") ? monObj.y : 0
            readonly property real aspect: monLW > 0 ? monLH / monLW : 0.5625

            // Espacio de trabajo activo actualmente
            readonly property int activeWsId: {
                if (monObj && monObj.activeWorkspace && typeof monObj.activeWorkspace.id === "number")
                    return monObj.activeWorkspace.id;
                var fw = Hyprland.focusedWorkspace;
                return fw ? fw.id : 1;
            }

            // Lista de IDs de workspaces visibles en este monitor
            property var wsList: {
                var ids = {};
                var list = [];
                var allWs = Hyprland.workspaces.values;
                for (var i = 0; i < allWs.length; i++) {
                    var w = allWs[i];
                    if (w && w.id > 0) {
                        if (!w.monitor || w.monitor.name === modelData.name) {
                            ids[w.id] = true;
                            list.push(w.id);
                        }
                    }
                }
                var maxId = 5;
                for (var k = 0; k < list.length; k++) {
                    if (list[k] > maxId) maxId = list[k];
                }
                for (var j = 1; j <= Math.min(10, Math.max(5, maxId + 1)); j++) {
                    if (!ids[j]) {
                        ids[j] = true;
                        list.push(j);
                    }
                }
                list.sort(function(a, b) { return a - b; });
                return list;
            }

            property int selectedIndex: {
                for (var i = 0; i < wsList.length; i++) {
                    if (wsList[i] === activeWsId) return i;
                }
                return 0;
            }

            function cycleSelection(step) {
                if (wsList.length === 0) return;
                selectedIndex = (selectedIndex + step + wsList.length) % wsList.length;
            }

            function commitSelection() {
                if (selectedIndex >= 0 && selectedIndex < wsList.length) {
                    Hyprland.dispatch("workspace " + wsList[selectedIndex]);
                }
                Qt.quit();
            }

            // Fondo translúcido oscurecido con alto contraste
            Rectangle {
                anchors.fill: parent
                color: theme.scrim
                MouseArea {
                    anchors.fill: parent
                    onClicked: Qt.quit()
                }
            }

            // Contenedor principal centrado
            ColumnLayout {
                anchors.centerIn: parent
                width: Math.min(win.width * 0.94, 1600)
                spacing: 30

                // Cabecera estilizada de alto contraste con icono Arch Nerd Font
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 16

                    Rectangle {
                        width: 36
                        height: 36
                        radius: theme.badgeRadius
                        color: theme.accent

                        Text {
                            anchors.centerIn: parent
                            text: "\uf303" //  Arch Linux logo nativo en Nerd Font
                            font.family: theme.fontMono
                            font.pixelSize: 20
                            color: theme.badgeBg
                        }
                    }

                    Column {
                        spacing: 3
                        Text {
                            text: "VISTA GENERAL DE ESCRITORIOS"
                            font.family: theme.fontMono
                            font.pixelSize: 17
                            font.bold: true
                            font.letterSpacing: 2
                            color: theme.textPrimary
                        }
                        Text {
                            text: "Tab / Flechas: navegar  •  Enter / Clic: entrar  •  Esc: cerrar"
                            font.family: theme.fontMono
                            font.pixelSize: 12
                            color: theme.textSecondary
                        }
                    }
                }

                // Tira de escritorios (Workspace Cards)
                Flickable {
                    id: flick
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: Math.min(cardsRow.implicitWidth, win.width * 0.92)
                    Layout.preferredHeight: 320
                    contentWidth: cardsRow.implicitWidth
                    contentHeight: 320
                    clip: false
                    boundsBehavior: Flickable.StopAtBounds

                    Row {
                        id: cardsRow
                        spacing: 22
                        anchors.verticalCenter: parent.verticalCenter

                        Repeater {
                            model: win.wsList

                            delegate: Item {
                                id: cardItem
                                required property int modelData
                                required property int index

                                readonly property int wsId: cardItem.modelData
                                readonly property bool isCurrent: wsId === win.activeWsId
                                readonly property bool isSelected: cardItem.index === win.selectedIndex
                                property bool hovered: false

                                width: 340
                                height: 215

                                // Sombra tridimensional offset
                                Rectangle {
                                    x: (cardItem.isSelected || cardItem.hovered) ? 10 : 6
                                    y: (cardItem.isSelected || cardItem.hovered) ? 10 : 6
                                    width: cardInner.width
                                    height: cardInner.height
                                    radius: theme.cardRadius
                                    color: theme.shadow
                                    opacity: cardItem.isSelected ? 0.95 : 0.75
                                    Behavior on x { NumberAnimation { duration: 120 } }
                                    Behavior on y { NumberAnimation { duration: 120 } }
                                    Behavior on opacity { NumberAnimation { duration: 120 } }
                                }

                                // Contenedor visual del workspace
                                Rectangle {
                                    id: cardInner
                                    anchors.fill: parent
                                    radius: theme.cardRadius
                                    color: cardItem.isCurrent ? theme.cardBgActive : theme.cardBg
                                    border.width: (cardItem.isSelected || cardItem.isCurrent) ? 2 : 1
                                    border.color: cardItem.isSelected ? theme.cardBorderSelect
                                                : cardItem.isCurrent ? theme.accentAlt
                                                : cardItem.hovered ? theme.cardBorderHover
                                                : theme.cardBorder
                                    clip: true

                                    Behavior on border.color { ColorAnimation { duration: 120 } }
                                    Behavior on color { ColorAnimation { duration: 120 } }

                                    // Badge numeral del Workspace (01, 02...)
                                    Rectangle {
                                        id: badge
                                        anchors.top: parent.top
                                        anchors.left: parent.left
                                        anchors.margins: 10
                                        width: 44
                                        height: 28
                                        radius: theme.badgeRadius
                                        color: theme.badgeBg
                                        border.width: 1
                                        border.color: cardItem.isSelected ? theme.cardBorderSelect : theme.badgeBorder
                                        z: 10

                                        Text {
                                            anchors.centerIn: parent
                                            text: (cardItem.wsId < 10 ? "0" : "") + cardItem.wsId
                                            font.family: theme.fontMono
                                            font.pixelSize: 13
                                            font.bold: true
                                            color: cardItem.isSelected ? theme.cardBorderSelect
                                                 : cardItem.isCurrent ? theme.accent
                                                 : theme.textSecondary
                                        }
                                    }

                                    // Fila de iconos de las aplicaciones abiertas en este escritorio
                                    Row {
                                        anchors.top: badge.bottom
                                        anchors.left: badge.left
                                        anchors.topMargin: 6
                                        spacing: 4
                                        visible: cardInner.winCards.length > 0
                                        z: 10

                                        Repeater {
                                            model: {
                                                var seen = {};
                                                var list = [];
                                                for (var i = 0; i < cardInner.winCards.length && list.length < 5; i++) {
                                                    var c = cardInner.winCards[i].cls;
                                                    if (!c || seen[c]) continue;
                                                    seen[c] = true;
                                                    var e = DesktopEntries.heuristicLookup(c);
                                                    var ico = (e && e.icon) ? e.icon : "application-x-executable";
                                                    list.push(ico);
                                                }
                                                return list;
                                            }

                                            delegate: Rectangle {
                                                required property string modelData
                                                width: 20
                                                height: 20
                                                radius: 4
                                                color: Qt.rgba(0.06, 0.07, 0.10, 0.85)
                                                border.width: 1
                                                border.color: theme.cardBorder

                                                IconImage {
                                                    anchors.centerIn: parent
                                                    implicitSize: 14
                                                    source: parent.modelData
                                                }
                                            }
                                        }
                                    }

                                    // Indicador "ACTIVO" en el workspace actual
                                    Rectangle {
                                        anchors.top: parent.top
                                        anchors.right: parent.right
                                        anchors.margins: 10
                                        width: 60
                                        height: 20
                                        radius: 4
                                        visible: cardItem.isCurrent
                                        color: Qt.rgba(theme.accentAlt.r, theme.accentAlt.g, theme.accentAlt.b, 0.20)
                                        border.width: 1
                                        border.color: theme.accentAlt
                                        z: 10

                                        Text {
                                            anchors.centerIn: parent
                                            text: "ACTIVO"
                                            font.family: theme.fontMono
                                            font.pixelSize: 9
                                            font.bold: true
                                            font.letterSpacing: 1
                                            color: theme.accentAlt
                                        }
                                    }

                                    // Lista de ventanas en este workspace
                                    readonly property var winCards: {
                                        var raw = [];
                                        var tls = Hyprland.toplevels.values;
                                        for (var i = 0; i < tls.length; i++) {
                                            var t = tls[i];
                                            var o = t && t.lastIpcObject;
                                            if (!t || !t.workspace || t.workspace.id !== cardItem.wsId) continue;
                                            if (!o || !o.at || !o.size || o.mapped === false) continue;

                                            var ax = o.at[0] - win.monX;
                                            var ay = o.at[1] - win.monY;
                                            var aw = o.size[0];
                                            var ah = o.size[1];

                                            raw.push({
                                                address: o.address,
                                                title: o.title || "",
                                                cls: (o.class || "").toLowerCase(),
                                                tl: t,
                                                rx: Math.max(0, ax / win.monLW),
                                                ry: Math.max(0, ay / win.monLH),
                                                rw: Math.min(1, Math.max(0.12, aw / win.monLW)),
                                                rh: Math.min(1, Math.max(0.12, ah / win.monLH))
                                            });
                                        }
                                        return raw;
                                    }

                                    // Estado cuando el workspace no tiene ventanas
                                    Text {
                                        anchors.centerIn: parent
                                        visible: cardInner.winCards.length === 0
                                        text: "VACÍO"
                                        font.family: theme.fontMono
                                        font.pixelSize: 13
                                        font.bold: true
                                        font.letterSpacing: 2
                                        color: theme.textMuted
                                    }

                                    // Renderizado de las ventanas en miniatura
                                    Repeater {
                                        model: cardInner.winCards

                                        delegate: Rectangle {
                                            id: winTile
                                            required property var modelData

                                            x: modelData.rx * cardInner.width
                                            y: modelData.ry * cardInner.height
                                            width: Math.max(38, modelData.rw * cardInner.width)
                                            height: Math.max(28, modelData.rh * cardInner.height)
                                            radius: theme.windowRadius
                                            color: theme.windowBg
                                            border.width: 1
                                            border.color: winMa.containsMouse ? theme.windowBorderHover : theme.windowBorder
                                            clip: true
                                            z: 5

                                            // Icono de la aplicación en el centro como respaldo visual
                                            IconImage {
                                                anchors.centerIn: parent
                                                implicitSize: Math.max(16, Math.min(32, Math.min(parent.width, parent.height) * 0.48))
                                                source: {
                                                    var c = winTile.modelData.cls;
                                                    var e = c ? DesktopEntries.heuristicLookup(c) : null;
                                                    return (e && e.icon) ? e.icon : "application-x-executable";
                                                }
                                                opacity: 0.80
                                            }

                                            // Captura en vivo de la ventana mediante Wayland ScreencopyView
                                            ScreencopyView {
                                                anchors.fill: parent
                                                captureSource: (winTile.modelData.tl && winTile.modelData.tl.wayland)
                                                    ? winTile.modelData.tl.wayland : null
                                                live: false
                                                visible: captureSource !== null
                                            }

                                            // Barra de título inferior con mini-icono y nombre
                                            Rectangle {
                                                anchors.bottom: parent.bottom
                                                anchors.left: parent.left
                                                anchors.right: parent.right
                                                height: 18
                                                color: theme.windowTitleBg
                                                border.width: 1
                                                border.color: Qt.rgba(theme.textMuted.r, theme.textMuted.g, theme.textMuted.b, 0.25)

                                                RowLayout {
                                                    anchors.fill: parent
                                                    anchors.leftMargin: 4
                                                    anchors.rightMargin: 4
                                                    spacing: 4

                                                    IconImage {
                                                        implicitSize: 11
                                                        source: {
                                                            var c = winTile.modelData.cls;
                                                            var e = c ? DesktopEntries.heuristicLookup(c) : null;
                                                            return (e && e.icon) ? e.icon : "application-x-executable";
                                                        }
                                                    }

                                                    Text {
                                                        Layout.fillWidth: true
                                                        text: winTile.modelData.title || winTile.modelData.cls
                                                        font.family: theme.fontMono
                                                        font.pixelSize: 9
                                                        font.bold: true
                                                        color: theme.textPrimary
                                                        elide: Text.ElideRight
                                                        verticalAlignment: Text.AlignVCenter
                                                    }
                                                }
                                            }

                                            MouseArea {
                                                id: winMa
                                                anchors.fill: parent
                                                hoverEnabled: true
                                                cursorShape: Qt.PointingHandCursor
                                                onClicked: {
                                                    Hyprland.dispatch("focuswindow address:" + winTile.modelData.address);
                                                    Qt.quit();
                                                }
                                            }
                                        }
                                    }

                                    // Clic en el área del workspace para seleccionarlo
                                    MouseArea {
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onEntered: cardItem.hovered = true
                                        onExited: cardItem.hovered = false
                                        onClicked: {
                                            Hyprland.dispatch("workspace " + cardItem.wsId);
                                            Qt.quit();
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // Manejo de eventos de teclado (Navegación completa por flechas/tab)
            FocusScope {
                anchors.fill: parent
                focus: win.isFocused
                Keys.onPressed: (event) => {
                    if (event.key === Qt.Key_Escape) {
                        Qt.quit();
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Tab || event.key === Qt.Key_Right) {
                        win.cycleSelection(1);
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Backtab || event.key === Qt.Key_Left) {
                        win.cycleSelection(-1);
                        event.accepted = true;
                    } else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                        win.commitSelection();
                        event.accepted = true;
                    }
                }
            }
        }
    }
}
