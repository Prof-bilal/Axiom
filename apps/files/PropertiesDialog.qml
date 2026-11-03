import QtQuick
import qs.src.shared
import qs.apps.shared
import "files.js" as Files

// Read-only properties of one item. Values come from the listing plus
// stat/gio (real owner, permissions and content type), never invented.
DialogFrame {
    id: dlg

    property var info: ({})
    cardWidth: 480

    function show(i) {
        info = i
        title = i.name
        open = true
        forceActiveFocus()
    }

    onDismissed: open = false

    component Row2: Row {
        property string label: ""
        property string value: ""
        visible: value.length > 0
        width: parent ? parent.width : 0
        spacing: Theme.spacingMd
        Text {
            width: 110
            text: parent.label
            color: Theme.textSecondary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontCaption
        }
        Text {
            width: parent.width - 110 - Theme.spacingMd
            text: parent.value
            color: Theme.textPrimary
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
            wrapMode: Text.WrapAnywhere
        }
    }

    Row2 { label: "Kind"; value: dlg.info.kind || "" }
    Row2 { label: "Type"; value: dlg.info.contentType || "" }
    Row2 { label: dlg.info.isTrash ? "Original location" : "Location"; value: dlg.info.path || "" }
    Row2 { label: "Link target"; value: dlg.info.target || "" }
    Row2 {
        label: "Size"
        value: dlg.info.isDir ? "" : (Files.humanSize(dlg.info.sizeExact !== undefined ? dlg.info.sizeExact : (dlg.info.size || 0))
                                      + (dlg.info.sizeExact > 999 ? " (" + dlg.info.sizeExact + " bytes)" : ""))
    }
    Row2 { label: "Modified"; value: dlg.info.modified ? dlg.info.modified.replace(/\.\d+/, "") : "" }
    Row2 { label: "Owner"; value: dlg.info.owner || "" }
    Row2 { label: "Permissions"; value: dlg.info.perms || "" }

    Row {
        anchors.right: parent.right
        AppButton { text: "Close"; primary: true; onClicked: dlg.open = false }
    }
}
