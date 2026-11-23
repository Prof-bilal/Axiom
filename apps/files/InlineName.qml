import QtQuick
import qs.src.shared
import "files.js" as Files

// The name of a file or folder, edited in place (Windows style). Created only while editing, so it takes
// focus and selects the part before the extension as soon as it appears.
//   Enter      keeps the new name if it is valid; otherwise `rejected` says why and editing continues
//   Esc        cancels (a just-created item keeps its default name)
//   click away keeps a valid name, cancels an invalid one
Item {
    id: root

    property string original: ""
    property var existing: []        // names already in the folder
    property bool centered: false
    // The box is as wide as the text plus some breathing room, up to the space the parent can give.
    property real maxWidth: 320
    property bool showReason: false  // draw the reason under the box (the desktop has no status bar)
    signal committed(string name)
    signal cancelled()
    signal rejected(string reason)

    readonly property string problem: Files.nameProblem(input.text, original, existing)
    property bool armed: false       // true once the box has had focus, so a late focus change is not a click-away
    property bool settled: false     // true once the edit has ended

    implicitHeight: 26
    width: Math.min(maxWidth, Math.max(96, fit.advanceWidth + 32))
    Behavior on width { NumberAnimation { duration: 80; easing.type: Easing.OutCubic } }

    TextMetrics {
        id: fit
        font: input.font
        text: input.text.length > 0 ? input.text : "M"
    }

    function accept() {
        if (settled) return
        if (problem.length > 0) { rejected(problem); return }
        settled = true
        committed(input.text)
    }
    function cancel() {
        if (settled) return
        settled = true
        cancelled()
    }

    Rectangle {
        anchors.fill: parent
        radius: Theme.radiusControl
        color: Theme.surface
        border.width: 1
        border.color: root.problem.length > 0 ? "#FF6B6B" : Theme.accent
    }

    TextInput {
        id: input
        anchors.fill: parent
        anchors.leftMargin: 6
        anchors.rightMargin: 6
        verticalAlignment: TextInput.AlignVCenter
        horizontalAlignment: root.centered ? TextInput.AlignHCenter : TextInput.AlignLeft
        clip: true
        text: root.original
        color: Theme.textPrimary
        selectionColor: Theme.accent
        selectedTextColor: Theme.background
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontBody
        Accessible.name: "File name"
        Accessible.description: root.problem

        Keys.onReturnPressed: function (e) { e.accepted = true; root.accept() }
        Keys.onEnterPressed: function (e) { e.accepted = true; root.accept() }
        Keys.onEscapePressed: function (e) { e.accepted = true; root.cancel() }
        // Keys the list would use to move the selection or leave the folder must not act while typing.
        Keys.onPressed: function (e) {
            if (e.key === Qt.Key_Up || e.key === Qt.Key_Down || e.key === Qt.Key_PageUp || e.key === Qt.Key_PageDown)
                e.accepted = true
        }
        onActiveFocusChanged: {
            if (activeFocus) root.armed = true
            // Only a click inside this window ends the edit; switching to another app keeps it open.
            else if (root.armed && !root.settled && root.Window.active) { if (root.problem.length > 0) root.cancel(); else root.accept() }
        }
    }

    Text {
        visible: root.showReason && root.problem.length > 0 && input.text !== root.original
        anchors.top: parent.bottom
        anchors.topMargin: 3
        anchors.horizontalCenter: parent.horizontalCenter
        width: Math.max(parent.width, 120)
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        text: root.problem
        color: "#FF8A8A"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontCaption
        style: Text.Outline
        styleColor: Qt.rgba(0, 0, 0, 0.7)
    }

    Component.onCompleted: Qt.callLater(function () {
        input.forceActiveFocus()
        input.select(0, Files.stemLength(root.original))
    })
}
