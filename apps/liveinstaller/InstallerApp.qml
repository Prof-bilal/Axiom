import QtQuick
import Quickshell
import qs.src.shared
import qs.apps.shared
import "installer.js" as Ins

// Axiom installer, run from the live desktop (ADR-035). A fixed-size window: a step list on the left,
// one page on the right and a footer with the status line and the two actions. All state and every
// system call live in InstallerBackend; the root step is the pkexec helper, never this UI.
AppWindow {
    id: root

    title: "Install Axiom"
    implicitWidth: 860
    implicitHeight: 580
    minimumSize: Qt.size(860, 580)
    maximumSize: Qt.size(860, 580)

    InstallerBackend { id: be; popup: dropdownList; Component.onCompleted: load() }

    readonly property var pages: [pWelcome, pNetwork, pLocale, pDisk, pIdentity, pConfirm, pProgress, pFinish]
    readonly property var cur: pages[be.page]
    readonly property int activeStep: Ins.PAGE_STEP[be.page]

    Rectangle { anchors.fill: parent; color: Ins.C.bg }

    // Title strip: the compositor draws no frame for this window, so the app names itself.
    Rectangle {
        id: bar
        anchors.top: parent.top
        width: parent.width
        height: 34
        color: Ins.C.bar
        IText { anchors.centerIn: parent; text: "Install Axiom"; font.pixelSize: 13; font.weight: Font.Medium; wrapMode: Text.NoWrap }
    }

    Rectangle {
        id: side
        anchors.top: bar.bottom
        anchors.bottom: foot.top
        width: 196
        color: Ins.C.side

        Row {
            id: logo
            anchors.top: parent.top
            anchors.topMargin: 14
            anchors.left: parent.left
            anchors.leftMargin: 16
            spacing: 10
            Image { source: "assets/axiom-penguin.png"; width: 34; height: 34; fillMode: Image.PreserveAspectFit; smooth: true; mipmap: true }
            Column {
                anchors.verticalCenter: parent.verticalCenter
                IText { text: "Axiom Installer"; font.pixelSize: 13; wrapMode: Text.NoWrap }
                IText { text: "v1.0"; font.pixelSize: 11; color: Ins.C.dim }
            }
        }
        Column {
            anchors.top: logo.bottom
            anchors.topMargin: 18
            width: parent.width
            Repeater {
                model: Ins.STEPS
                delegate: Rectangle {
                    required property string modelData
                    required property int index
                    width: side.width
                    height: 40
                    color: index === root.activeStep ? "#1d2227" : "transparent"
                    Rectangle { width: 3; height: parent.height; color: index === root.activeStep ? Ins.C.orange : "transparent" }
                    Row {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 18
                        spacing: 12
                        IText {
                            width: 14
                            text: index < root.activeStep ? "✓" : index === root.activeStep ? "●" : "○"
                            color: index === root.activeStep ? Ins.C.orange : index < root.activeStep ? Ins.C.text : Ins.C.faint
                            font.pixelSize: 13
                        }
                        IText {
                            text: modelData
                            color: index === root.activeStep ? "#ffffff" : index < root.activeStep ? Ins.C.text : Ins.C.dim
                            wrapMode: Text.NoWrap
                        }
                    }
                }
            }
        }
    }

    Item {
        id: stage
        anchors.top: bar.bottom
        anchors.bottom: foot.top
        anchors.left: side.right
        anchors.right: parent.right
        anchors.margins: 22

        WelcomePage  { id: pWelcome;  anchors.fill: parent; be: be; visible: be.page === 0 }
        NetworkPage  { id: pNetwork;  anchors.fill: parent; be: be; visible: be.page === 1 }
        LocalePage   { id: pLocale;   anchors.fill: parent; be: be; visible: be.page === 2 }
        DiskPage     { id: pDisk;     anchors.fill: parent; be: be; visible: be.page === 3 }
        IdentityPage { id: pIdentity; anchors.fill: parent; be: be; visible: be.page === 4 }
        ConfirmPage  { id: pConfirm;  anchors.fill: parent; be: be; visible: be.page === 5 }
        ProgressPage { id: pProgress; anchors.fill: parent; be: be; visible: be.page === 6 }
        FinishPage   { id: pFinish;   anchors.fill: parent; be: be; visible: be.page === 7 }
    }

    Rectangle {
        id: foot
        anchors.bottom: parent.bottom
        width: parent.width
        height: 56
        color: Ins.C.bg
        Rectangle { width: parent.width; height: 1; color: Ins.C.line }

        IText {
            anchors.left: parent.left
            anchors.leftMargin: 18
            anchors.right: buttons.left
            anchors.rightMargin: 16
            anchors.verticalCenter: parent.verticalCenter
            text: be.formError.length > 0 ? be.formError : (be.busy ? "Checking…" : root.cur.status)
            color: be.formError.length > 0 ? Ins.C.red : Ins.C.text
            font.pixelSize: 13
            elide: Text.ElideRight
            wrapMode: Text.NoWrap
        }
        Row {
            id: buttons
            anchors.right: parent.right
            anchors.rightMargin: 18
            anchors.verticalCenter: parent.verticalCenter
            spacing: 10
            InstallerButton { text: root.cur.secondaryText; enabled: !be.busy && !be.installing; onClicked: root.cur.doSecondary() }
            InstallerButton {
                text: root.cur.primaryText
                primary: !root.cur.primaryDanger
                danger: root.cur.primaryDanger
                enabled: !be.busy && !be.installing
                onClicked: root.cur.doPrimary()
            }
        }
    }

    // Above everything: the list every Dropdown opens.
    DropdownList { id: dropdownList; anchors.fill: parent; z: 100 }
}
