import QtQuick
import qs.src.shared

// A plain statement of why something is unavailable. Pages use it instead of
// hiding the control, so "no adapter" and "service not running" are visible.
Rectangle {
    id: notice

    property string text: ""
    property bool warning: false

    width: parent ? parent.width : 0
    height: label.implicitHeight + Theme.spacingMd * 2
    radius: Theme.radiusSurface
    color: warning ? Theme.stateUrgentWash : Theme.surfaceElevated
    border.width: 1
    border.color: warning ? Theme.orangeMuted : Theme.borderSubtle

    Text {
        id: label
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        text: notice.text
        wrapMode: Text.Wrap
        color: notice.warning ? Theme.orangeBright : Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontBody
    }
}
