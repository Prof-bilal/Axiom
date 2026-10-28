pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import "services"
import "theme"

// Real, non-exclusive layer-shell controls for the current native toplevel.
// The panel observes the active object and never invents application state.
ShellRoot {
    id: root
    property var theme: AxiomTheme {}
    property var actions: WindowActions {}

    Variants {
        model: Quickshell.screens
        // PanelWindow is the Quickshell default-import alias over the native
        // layer-shell implementation; qmltypes marks its interface abstract.
        // qmllint disable uncreatable-type
        PanelWindow {
            id: panel
            required property var modelData
            screen: modelData
            visible: root.actions.windowState.available
            implicitWidth: 342
            implicitHeight: 54
            anchors { top: true; left: true }
            // qmllint disable unresolved-type
            // qmllint disable unqualified
            margins { top: root.theme.spacingMedium; left: root.theme.spacingMedium }
            // qmllint enable unqualified
            // qmllint enable unresolved-type
            exclusiveZone: 0
            exclusionMode: ExclusionMode.Ignore
            focusable: false
            aboveWindows: true
            color: "transparent"
            surfaceFormat.opaque: false
            WlrLayershell.namespace: "axiom-window-controls"
            WlrLayershell.layer: WlrLayer.Top

            Rectangle {
                anchors.fill: parent
                radius: root.theme.radiusSurface
                color: Qt.rgba(0.08, 0.10, 0.12, 0.94)
                border.width: 1
                border.color: Qt.rgba(0.39, 0.85, 0.77, 0.34)

                Row {
                    anchors.fill: parent
                    anchors.margins: root.theme.spacingSmall
                    spacing: root.theme.spacingSmall

                    Image {
                        width: 32
                        height: 32
                        anchors.verticalCenter: parent.verticalCenter
                        source: Quickshell.shellPath("../branding/theme/axiom/icons/axiom-penguin.svg")
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                        Accessible.name: "Axiom"
                    }

                    Column {
                        width: 132
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 1
                        Text {
                            width: parent.width
                            elide: Text.ElideRight
                            text: root.actions.windowState.activeWindow && root.actions.windowState.activeWindow.wayland
                                  ? root.actions.windowState.activeWindow.wayland.appId : "No active window"
                            color: root.theme.foreground
                            font.pixelSize: 12
                            Accessible.name: text
                        }
                        Text {
                            width: parent.width
                            elide: Text.ElideRight
                            text: root.actions.busy ? "Working…" : (root.actions.lastResult.status === "verified"
                                  ? "Verified" : root.actions.lastResult.status === "idle" ? "Ready" : root.actions.lastResult.status)
                            color: root.actions.lastResult.status === "failed" || root.actions.lastResult.status === "timeout"
                                   ? root.theme.danger : root.theme.muted
                            font.pixelSize: 10
                        }
                    }

                    Button {
                        id: minimize
                        width: root.theme.pointerTarget
                        height: root.theme.pointerTarget
                        anchors.verticalCenter: parent.verticalCenter
                        focusPolicy: Qt.NoFocus
                        text: "−"
                        enabled: !root.actions.busy && root.actions.windowState.activeWindow !== null
                        Accessible.name: root.actions.windowState.activeWindow && root.actions.isMinimized(root.actions.windowState.activeWindow)
                                         ? "Restore active window" : "Minimize active window"
                        onClicked: {
                            const window = root.actions.windowState.activeWindow;
                            if (!window) return;
                            const op = root.actions.isMinimized(window) ? "restore-minimize" : "minimize";
                            root.actions.request("0x" + window.address, op);
                        }
                        background: Rectangle {
                            radius: root.theme.radiusControl
                            color: minimize.down ? root.theme.warning : Qt.rgba(0.95, 0.72, 0.28, 0.17)
                            border.color: Qt.rgba(0.95, 0.72, 0.28, 0.45)
                            border.width: 1
                        }
                        contentItem: Text {
                            text: minimize.text
                            color: root.theme.foreground
                            font.pixelSize: 19
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        id: maximize
                        width: root.theme.pointerTarget
                        height: root.theme.pointerTarget
                        anchors.verticalCenter: parent.verticalCenter
                        focusPolicy: Qt.NoFocus
                        text: "□"
                        enabled: !root.actions.busy && root.actions.windowState.activeWindow !== null
                        Accessible.name: root.actions.windowState.activeWindow && root.actions.windowState.activeWindow.wayland
                                         && root.actions.windowState.activeWindow.wayland.maximized
                                         ? "Restore active window size" : "Maximize active window"
                        onClicked: {
                            const window = root.actions.windowState.activeWindow;
                            if (!window) return;
                            const op = window.wayland && window.wayland.maximized ? "restore-maximize" : "maximize";
                            root.actions.request("0x" + window.address, op);
                        }
                        background: Rectangle {
                            radius: root.theme.radiusControl
                            color: maximize.down ? root.theme.accent : Qt.rgba(0.39, 0.85, 0.77, 0.17)
                            border.color: Qt.rgba(0.39, 0.85, 0.77, 0.45)
                            border.width: 1
                        }
                        contentItem: Text {
                            text: maximize.text
                            color: root.theme.foreground
                            font.pixelSize: 16
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Button {
                        id: close
                        width: root.theme.pointerTarget
                        height: root.theme.pointerTarget
                        anchors.verticalCenter: parent.verticalCenter
                        focusPolicy: Qt.NoFocus
                        text: "×"
                        enabled: !root.actions.busy && root.actions.windowState.activeWindow !== null
                        Accessible.name: "Close active window"
                        onClicked: {
                            const window = root.actions.windowState.activeWindow;
                            if (window) root.actions.request("0x" + window.address, "close");
                        }
                        background: Rectangle {
                            radius: root.theme.radiusControl
                            color: close.down ? root.theme.danger : Qt.rgba(1.0, 0.61, 0.61, 0.17)
                            border.color: Qt.rgba(1.0, 0.61, 0.61, 0.45)
                            border.width: 1
                        }
                        contentItem: Text {
                            text: close.text
                            color: root.theme.foreground
                            font.pixelSize: 19
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }
                }
            }
        }
    }
}
