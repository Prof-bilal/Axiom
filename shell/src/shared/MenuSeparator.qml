import QtQuick
import qs.src.shared

// Hairline between menu groups, with an optional small section caption.
Item {
    id: sep
    property string caption: ""

    width: parent ? parent.width : 0
    implicitHeight: caption.length > 0 ? 28 : 11

    Rectangle {
        visible: sep.caption.length === 0
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: Theme.spacingXs
        anchors.rightMargin: Theme.spacingXs
        height: 1
        color: Theme.borderSubtle
    }

    Text {
        visible: sep.caption.length > 0
        anchors.left: parent.left
        anchors.leftMargin: Theme.spacingSm
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.spacingXs
        text: sep.caption.toUpperCase()
        color: Theme.textDisabled
        font.family: Theme.fontFamily
        font.pixelSize: 10
        font.weight: Font.DemiBold
        font.letterSpacing: 0.8
    }
}
