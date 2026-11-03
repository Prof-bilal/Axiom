import QtQuick
import qs.src.shared

// Places, Trash, File System and mounted devices. Entries come from the
// backend probes (real directories under $HOME, real mounts); nothing is
// listed that does not exist.
Rectangle {
    id: bar

    property var backend

    width: 200
    color: Theme.surface

    function iconFor(name) {
        switch (name) {
        case "Documents": return "document"
        case "Downloads": return "download"
        case "Music": return "audio"
        case "Pictures": return "image"
        case "Videos": return "video"
        case "Desktop": return "window"
        default: return "folder"
        }
    }

    readonly property var rows: {
        var a = [{ section: "Places" },
                 { name: "Home", icon: "home", path: backend.home }]
        backend.places.forEach(function (p) { a.push({ name: p.name, icon: bar.iconFor(p.name), path: p.path }) })
        a.push({ name: "Trash", icon: "trash", path: backend.trashUri })
        a.push({ name: "File System", icon: "disk", path: "/" })
        if (backend.devices.length > 0) {
            a.push({ section: "Devices" })
            backend.devices.forEach(function (d) { a.push({ name: d.name, icon: "disk", path: d.path }) })
        }
        return a
    }

    Rectangle {
        anchors.right: parent.right
        width: 1
        height: parent.height
        color: Theme.borderSubtle
    }

    Column {
        anchors.fill: parent
        anchors.margins: Theme.spacingSm
        anchors.topMargin: Theme.spacingMd
        spacing: 2

        Repeater {
            model: bar.rows
            delegate: Item {
                required property var modelData
                width: parent.width
                height: modelData.section ? 30 : 32

                Text {
                    visible: !!modelData.section
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacingMd
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 4
                    text: modelData.section ? modelData.section.toUpperCase() : ""
                    color: Theme.textDisabled
                    font.family: Theme.fontFamily
                    font.pixelSize: 10
                    font.weight: Font.DemiBold
                    font.letterSpacing: 0.8
                }

                Rectangle {
                    visible: !modelData.section
                    anchors.fill: parent
                    radius: Theme.radiusControl
                    readonly property bool active: modelData.path === bar.backend.path
                    color: active ? Theme.stateSelected : (hit.containsMouse ? Theme.stateHover : "transparent")
                    border.width: active ? 1 : 0
                    border.color: Theme.stateSelectedBorder

                    Accessible.role: Accessible.Button
                    Accessible.name: modelData.name || ""

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacingMd
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.spacingMd

                        AxiomIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 18
                            height: 18
                            name: modelData.icon || "folder"
                            color: parent.parent.active ? Theme.cyanBright : Theme.textSecondary
                            strokeWidth: 1.5
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.name || ""
                            color: parent.parent.active ? Theme.textPrimary : Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontBody
                            font.weight: parent.parent.active ? Font.Medium : Font.Normal
                        }
                    }

                    MouseArea {
                        id: hit
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: bar.backend.navigate(modelData.path)
                    }
                }
            }
        }
    }
}
