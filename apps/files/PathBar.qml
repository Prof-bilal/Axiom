import QtQuick
import qs.src.shared
import "files.js" as Files

// Breadcrumb path bar. Click a segment to go there; click the empty space (or
// press Ctrl+L) to type a path: Enter goes, Escape cancels. "~" and relative
// paths are resolved without touching the disk, the backend then reports
// whether the folder exists.
Rectangle {
    id: bar

    property var backend
    property bool editing: false

    signal editFinished()

    implicitHeight: 32
    radius: Theme.radiusControl
    color: Theme.background
    border.width: 1
    border.color: editing ? Theme.stateFocus : Theme.border

    function beginEdit() {
        editing = true
        field.text = backend.trashView ? backend.home : backend.path
        field.forceActiveFocus()
        field.selectAll()
    }

    function endEdit() {
        editing = false
        bar.editFinished()
    }

    readonly property var parts: backend.trashView ? [{ name: "Trash", path: backend.trashUri }]
                                                  : Files.segments(backend.path)

    Flickable {
        id: flick
        visible: !bar.editing
        anchors.fill: parent
        anchors.leftMargin: Theme.spacingSm
        anchors.rightMargin: Theme.spacingSm
        contentWidth: crumbs.width
        contentHeight: height
        clip: true
        interactive: contentWidth > width
        boundsBehavior: Flickable.StopAtBounds
        onContentWidthChanged: contentX = Math.max(0, contentWidth - width)

        Row {
            id: crumbs
            height: flick.height
            spacing: 0

            Repeater {
                model: bar.parts
                delegate: Row {
                    required property var modelData
                    required property int index
                    height: crumbs.height

                    AxiomIcon {
                        visible: index > 1
                        anchors.verticalCenter: parent.verticalCenter
                        width: 14
                        height: 14
                        name: "chevron-right"
                        color: Theme.textDisabled
                        strokeWidth: 1.5
                    }

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: label.implicitWidth + Theme.spacingMd
                        height: 24
                        radius: Theme.radiusSmall
                        color: crumb.containsMouse ? Theme.stateHover : "transparent"

                        Accessible.role: Accessible.Button
                        Accessible.name: modelData.name

                        Text {
                            id: label
                            anchors.centerIn: parent
                            text: modelData.name
                            color: index === bar.parts.length - 1 ? Theme.textPrimary : Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontBody
                            font.weight: index === bar.parts.length - 1 ? Font.Medium : Font.Normal
                        }

                        MouseArea {
                            id: crumb
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: bar.backend.navigate(modelData.path)
                        }
                    }
                }
            }
        }
    }

    // Empty space after the crumbs starts editing.
    MouseArea {
        visible: !bar.editing
        anchors.fill: parent
        z: -1
        onClicked: bar.beginEdit()
    }

    TextInput {
        id: field
        visible: bar.editing
        anchors.fill: parent
        anchors.leftMargin: Theme.spacingMd
        anchors.rightMargin: Theme.spacingMd
        verticalAlignment: TextInput.AlignVCenter
        color: Theme.textPrimary
        selectionColor: Theme.cyanMuted
        selectedTextColor: Theme.textPrimary
        font.family: Theme.fontFamilyMono
        font.pixelSize: Theme.fontCaption + 1
        clip: true
        Keys.onReturnPressed: { var t = text; bar.endEdit(); bar.backend.navigate(t) }
        Keys.onEnterPressed: { var t = text; bar.endEdit(); bar.backend.navigate(t) }
        Keys.onEscapePressed: bar.endEdit()
        onActiveFocusChanged: if (!activeFocus && bar.editing) bar.endEdit()
        Accessible.role: Accessible.EditableText
        Accessible.name: "Location"
    }
}
