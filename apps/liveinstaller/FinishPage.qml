import QtQuick
import "installer.js" as Ins

Item {
    id: page
    property var be
    readonly property string primaryText: "Restart now"
    readonly property string secondaryText: "Keep trying Axiom"
    readonly property bool primaryDanger: false
    readonly property string status: "Remove the install USB stick before restarting."
    function doPrimary() { be.restart() }
    function doSecondary() { Qt.quit() }

    Column {
        anchors.centerIn: parent
        spacing: 12
        Image { anchors.horizontalCenter: parent.horizontalCenter; source: "assets/axiom-penguin.png"; width: 150; height: 150; fillMode: Image.PreserveAspectFit; smooth: true; mipmap: true }
        IText { anchors.horizontalCenter: parent.horizontalCenter; text: "Axiom is ready"; font.pixelSize: 26; font.weight: Font.Medium; color: "#ffffff" }
        IText { anchors.horizontalCenter: parent.horizontalCenter; width: 340; horizontalAlignment: Text.AlignHCenter; text: "Remove the install USB stick, then restart to start using Axiom."; color: Ins.C.dim }
    }
}
