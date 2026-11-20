import QtQuick
import "installer.js" as Ins

// Centered page title and one line of explanation.
Column {
    property string title: ""
    property string subtitle: ""
    width: parent ? parent.width : 400
    spacing: 4
    IText { width: parent.width; horizontalAlignment: Text.AlignHCenter; text: parent.title; font.pixelSize: 26; font.weight: Font.Medium; color: "#ffffff" }
    IText { width: parent.width; horizontalAlignment: Text.AlignHCenter; text: parent.subtitle; color: Ins.C.dim; font.pixelSize: 13 }
}
