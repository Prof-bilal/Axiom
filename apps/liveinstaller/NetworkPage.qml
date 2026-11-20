import QtQuick
import Quickshell.Networking
import "installer.js" as Ins

// Join Wi-Fi before the install, using the same Quickshell.Networking service as Settings. The password
// goes straight to NetworkManager and is cleared at once; it is never logged or stored by the installer.
Item {
    id: page
    property var be

    readonly property var devices: Networking.devices ? Networking.devices.values : []
    readonly property var wifiDevices: devices.filter(function (d) { return d.type === DeviceType.Wifi })
    readonly property var wiredDevices: devices.filter(function (d) { return d.type === DeviceType.Wired })
    property string selected: ""
    property string netError: ""
    property bool reveal: false

    readonly property var selNet: {
        var found = null
        wifiDevices.forEach(function (d) {
            d.networks.values.forEach(function (n) { if (n.name === page.selected) found = n })
        })
        return found
    }
    function secured(n) { return n.security !== WifiSecurityType.Open && n.security !== WifiSecurityType.Owe }
    function bars(n) { return "▂▄▆█".slice(0, 1 + Math.min(3, Math.floor(n.signalStrength * 4))) }
    readonly property bool connecting: selNet !== null && selNet.state === ConnectionState.Connecting

    readonly property string primaryText: be.online ? "Next" : "Connect"
    readonly property string secondaryText: "Skip"
    readonly property bool primaryDanger: false
    readonly property string status: be.online ? "Connected to the internet."
        : connecting ? "Connecting…"
        : netError.length > 0 ? netError
        : "Searching for networks… Choose Skip to continue offline."

    function doSecondary() { be.go(2) }
    function doPrimary() {
        if (be.online) { be.next(); return }
        var n = selNet
        if (!n) { netError = "Pick a network first."; return }
        netError = ""
        if (secured(n) && !n.known) {
            if (psk.text.length < 8) { netError = "Enter the Wi-Fi password (at least 8 characters)."; return }
            n.connectWithPsk(psk.text)
            psk.text = ""
        } else {
            n.connect()
        }
        recheck.restart()
    }

    // After a join, ask the real question (can pacman reach its mirror?) a few times.
    Timer { id: recheck; interval: 3000; repeat: true; running: page.visible && !page.be.online; onTriggered: page.be.probeOnline() }

    PageHead {
        id: head
        anchors.top: parent.top
        anchors.topMargin: 6
        title: "Connect to Network"
        subtitle: "Choose a network to access the internet and download packages during installation."
    }

    Rectangle {
        id: wiredRow
        anchors.top: head.bottom
        anchors.topMargin: 14
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width - 60, 540)
        height: 36
        radius: 8
        color: Ins.C.card
        IText { anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter; text: "Wired connection (Ethernet)" }
        IText {
            anchors.right: parent.right; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter
            color: Ins.C.dim
            text: page.wiredDevices.length === 0 ? "No adapter"
                : page.wiredDevices[0].connected ? "Connected" : (page.wiredDevices[0].hasLink ? "Link up" : "Cable unplugged")
        }
    }

    Rectangle {
        id: list
        anchors.top: wiredRow.bottom
        anchors.topMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        width: wiredRow.width
        height: 150
        radius: 8
        color: Ins.C.side
        border.color: Ins.C.line
        clip: true

        IText {
            anchors.centerIn: parent
            visible: page.wifiDevices.length === 0
            color: Ins.C.dim
            text: Networking.wifiEnabled ? "No Wi-Fi adapter found. Use a cable, or choose Skip." : "Wi-Fi is turned off."
        }
        Flickable {
            anchors.fill: parent
            contentHeight: col.height
            boundsBehavior: Flickable.StopAtBounds
            Column {
                id: col
                width: parent.width
                Repeater {
                    model: Networking.wifiEnabled ? page.wifiDevices : []
                    delegate: Column {
                        id: dev
                        required property var modelData
                        width: col.width
                        Binding { target: dev.modelData; property: "scannerEnabled"; value: page.visible }
                        Repeater {
                            model: dev.modelData.networks.values
                            delegate: Rectangle {
                                id: row
                                required property var modelData
                                width: col.width
                                height: 34
                                color: row.modelData.name === page.selected ? "#262b31" : "transparent"
                                Connections {
                                    target: row.modelData
                                    function onConnectionFailed(reason) { page.netError = "Could not join " + row.modelData.name + ". Check the password." }
                                }
                                IText {
                                    anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter
                                    text: (row.modelData.connected ? "✓  " : "    ") + row.modelData.name
                                    color: row.modelData.name === page.selected ? "#ffffff" : Ins.C.text
                                    wrapMode: Text.NoWrap
                                }
                                IText {
                                    anchors.right: parent.right; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter
                                    color: Ins.C.dim
                                    text: (page.secured(row.modelData) ? "Secured  " : "") + page.bars(row.modelData)
                                }
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: { page.selected = row.modelData.name; page.netError = ""; psk.text = "" }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    Column {
        anchors.top: list.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: parent.horizontalCenter
        width: wiredRow.width
        spacing: 6
        visible: page.selNet !== null && page.secured(page.selNet) && !page.selNet.known && !page.be.online
        InstallerField {
            id: psk
            width: parent.width
            label: page.selected
            labelWidth: 150
            password: true
            reveal: page.reveal
            onAccepted: page.doPrimary()
        }
        Row {
            x: 150
            spacing: 8
            Rectangle {
                width: 18; height: 18; radius: 4
                color: page.reveal ? Ins.C.orange : Ins.C.field
                IText { anchors.centerIn: parent; visible: page.reveal; text: "✓"; color: Ins.C.orangeInk; font.pixelSize: 12 }
                MouseArea { anchors.fill: parent; onClicked: page.reveal = !page.reveal }
            }
            IText { text: "Show password"; color: Ins.C.dim; font.pixelSize: 13 }
        }
    }
    IText {
        anchors.top: list.bottom
        anchors.topMargin: 12
        anchors.horizontalCenter: parent.horizontalCenter
        width: wiredRow.width
        visible: page.selNet !== null && !page.secured(page.selNet)
        color: Ins.C.dim
        font.pixelSize: 13
        text: "This is an open network. No password is needed, but others nearby can see your traffic."
    }
}
