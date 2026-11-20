import QtQuick
import qs.src.shared
import "installer.js" as Ins

// The one popup list for every Dropdown. Fills the window so a click anywhere else closes it. Up/Down and
// Enter pick, Esc closes, and typing jumps to the next entry that starts with those letters (a time zone
// list has hundreds of entries). Clicking never changes the value until an entry is chosen.
Item {
    id: pop

    property bool opened: false
    property var items: []
    property string current: ""
    property var callback: null
    property real boxX: 0
    property real boxY: 0
    property real boxW: 200
    property real boxH: 34
    property string typed: ""
    readonly property real listH: Math.min(items.length * 34 + 8, 252)
    readonly property bool above: boxY + boxH + 4 + listH > height - 8

    visible: opened
    focus: opened

    function show(owner, values, names, value, cb) {
        var p = owner.mapToItem(pop, 0, 0)
        boxX = p.x
        boxY = p.y
        boxW = owner.width
        boxH = owner.height
        items = (values || []).map(function (v) { return { value: v, label: Ins.nameOf(names || {}, v) } })
        current = value
        callback = cb
        typed = ""
        var i = items.findIndex(function (x) { return x.value === value })
        list.currentIndex = i < 0 ? 0 : i
        opened = true
        forceActiveFocus()
        list.positionViewAtIndex(list.currentIndex, ListView.Center)
    }
    function close() { opened = false; callback = null }
    function choose(i) {
        if (i < 0 || i >= items.length) return
        var cb = callback
        var v = items[i].value
        close()
        if (cb) cb(v)
    }

    MouseArea { anchors.fill: parent; onClicked: pop.close() }

    Rectangle {
        x: Math.max(8, Math.min(pop.boxX, pop.width - pop.boxW - 8))
        y: pop.above ? pop.boxY - pop.listH - 4 : pop.boxY + pop.boxH + 4
        width: pop.boxW
        height: pop.listH
        radius: 8
        color: "#23282d"
        border.width: 1
        border.color: "#3a4048"
        clip: true

        ListView {
            id: list
            anchors.fill: parent
            anchors.margins: 4
            model: pop.items
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            delegate: Rectangle {
                required property var modelData
                required property int index
                width: list.width
                height: 34
                radius: 6
                color: index === list.currentIndex ? "#343a41" : "transparent"
                IText {
                    anchors.left: parent.left
                    anchors.leftMargin: 10
                    anchors.right: tick.left
                    anchors.verticalCenter: parent.verticalCenter
                    text: modelData.label
                    color: modelData.value === pop.current ? Ins.C.orange : Ins.C.text
                    elide: Text.ElideRight
                    wrapMode: Text.NoWrap
                }
                IText { id: tick; anchors.right: parent.right; anchors.rightMargin: 10; anchors.verticalCenter: parent.verticalCenter; text: modelData.value === pop.current ? "✓" : ""; color: Ins.C.orange }
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    onEntered: list.currentIndex = index
                    onClicked: pop.choose(index)
                }
            }
        }
    }

    Keys.onPressed: function (e) {
        if (e.key === Qt.Key_Escape) { close(); e.accepted = true }
        else if (e.key === Qt.Key_Down) { list.currentIndex = Math.min(list.currentIndex + 1, items.length - 1); e.accepted = true }
        else if (e.key === Qt.Key_Up) { list.currentIndex = Math.max(list.currentIndex - 1, 0); e.accepted = true }
        else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) { choose(list.currentIndex); e.accepted = true }
        else if (e.text.length === 1 && e.text >= " ") {
            typed = (typeTimer.running ? typed : "") + e.text.toLowerCase()
            typeTimer.restart()
            for (var i = 0; i < items.length; i++) {
                if (items[i].label.toLowerCase().indexOf(typed) === 0) { list.currentIndex = i; list.positionViewAtIndex(i, ListView.Center); break }
            }
            e.accepted = true
        }
    }
    Timer { id: typeTimer; interval: 900 }
}
