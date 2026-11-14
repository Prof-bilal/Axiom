import QtQuick
import "hubstyle.js" as S

// App icon: the bundled vendor icon (icons/<id>.png from Flathub's appstream data) when
// there is one, otherwise the app's first letter on a tinted rounded square.
Rectangle {
    id: tile

    property var app: null
    property int size: 44
    readonly property color tone: app ? S.tint[app.category] : S.muted
    readonly property bool hasIcon: img.status === Image.Ready

    width: size
    height: size
    radius: size * 0.24
    color: hasIcon ? "transparent" : Qt.rgba(tone.r, tone.g, tone.b, 0.18)
    border.width: hasIcon ? 0 : 1
    border.color: Qt.rgba(tone.r, tone.g, tone.b, 0.45)

    Image {
        id: img
        anchors.fill: parent
        source: tile.app ? Qt.resolvedUrl("icons/" + tile.app.id + ".png") : ""
        sourceSize.width: tile.size * 2
        sourceSize.height: tile.size * 2
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
        asynchronous: true
    }

    Text {
        visible: !tile.hasIcon
        anchors.centerIn: parent
        text: tile.app ? tile.app.name.charAt(0) : ""
        color: tile.tone
        font.family: S.font
        font.pixelSize: tile.size * 0.46
        font.weight: Font.DemiBold
    }
}
