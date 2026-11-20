import QtQuick
import qs.src.shared
import "installer.js" as Ins

// Text in the installer's colours and the shared font.
Text {
    color: Ins.C.text
    font.family: Theme.fontFamily
    font.pixelSize: 14
    wrapMode: Text.WordWrap
}
