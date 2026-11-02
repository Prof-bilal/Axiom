import QtQuick
import qs.src.shared

// Application icon from the XDG icon theme. When the theme has no icon for an
// entry, an Axiom fallback glyph is drawn instead of Qt's missing-image
// texture. `source` is a resolved path from ApplicationService.
Item {
    id: root
    property string source: ""
    property int size: 32

    implicitWidth: size
    implicitHeight: size

    Image {
        id: img
        anchors.fill: parent
        visible: root.source.length > 0 && status !== Image.Error
        source: root.source
        sourceSize.width: root.size * 2
        sourceSize.height: root.size * 2
        fillMode: Image.PreserveAspectFit
        smooth: true
        mipmap: true
        asynchronous: true
    }

    AxiomIcon {
        anchors.centerIn: parent
        width: root.size * 0.8
        height: root.size * 0.8
        visible: !img.visible
        name: "application"
        color: Theme.textSecondary
        strokeWidth: 1.5
    }
}
