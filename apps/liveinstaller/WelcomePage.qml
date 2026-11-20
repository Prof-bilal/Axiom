import QtQuick
import "installer.js" as Ins

Item {
    id: page
    property var be
    readonly property string primaryText: "Start Installation"
    readonly property string secondaryText: "Cancel"
    readonly property bool primaryDanger: false
    readonly property string status: "Ready to proceed. Ensure a power source is connected."
    function doPrimary() { be.next() }
    function doSecondary() { Qt.quit() }

    PageHead {
        id: head
        anchors.top: parent.top
        anchors.topMargin: 6
        title: "Welcome to Axiom Linux"
        subtitle: "A lightweight, developer-first, and highly optimized Linux distribution."
    }

    // A laptop drawn from rectangles, with our own penguin standing next to it.
    Item {
        id: art
        anchors.top: head.bottom
        anchors.topMargin: 14
        anchors.horizontalCenter: parent.horizontalCenter
        width: 300
        height: 150
        Rectangle { x: 40; y: 6; width: 190; height: 112; radius: 8; color: Ins.C.card; border.color: Ins.C.text; border.width: 2
            Rectangle { width: parent.width; height: 18; radius: 8; color: Ins.C.field }
            Rectangle { x: 10; y: 6; width: 6; height: 6; radius: 3; color: Ins.C.orange }
            Rectangle { x: 22; y: 6; width: 6; height: 6; radius: 3; color: Ins.C.dim }
            IText { x: 12; y: 32; text: ">_"; font.family: "monospace"; font.pixelSize: 20 }
        }
        Rectangle { x: 24; y: 118; width: 222; height: 12; radius: 4; color: Ins.C.field; border.color: Ins.C.text; border.width: 2 }
        Image {
            source: "assets/axiom-penguin.png"
            x: 196; y: 36; width: 100; height: 100
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
        }
        Rectangle { x: 14; y: 40; width: 8; height: 8; radius: 4; color: "transparent"; border.color: Ins.C.dim }
        Rectangle { x: 270; y: 14; width: 6; height: 6; radius: 3; color: Ins.C.orange }
    }

    IText {
        id: blurb
        anchors.top: art.bottom
        anchors.topMargin: 8
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width - 60, 460)
        horizontalAlignment: Text.AlignHCenter
        text: "We will guide you through setting up your first session and installing Axiom on this computer."
    }

    Column {
        anchors.top: blurb.bottom
        anchors.topMargin: 16
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.min(parent.width - 80, 460)
        spacing: 8
        Dropdown {
            be: page.be
            width: parent.width
            label: "Select language:"
            model: Ins.LOCALES
            names: Ins.LOCALE_NAMES
            value: page.be.form.locale
            onPicked: function (v) { page.be.set("locale", v) }
        }
        Dropdown {
            be: page.be
            width: parent.width
            label: "Keyboard:"
            model: Ins.KEYMAPS
            names: Ins.KEYMAP_NAMES
            value: page.be.form.keyboard
            onPicked: function (v) { page.be.set("keyboard", v) }
        }
    }
}
