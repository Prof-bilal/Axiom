import QtQuick
import qs.src.shared
import qs.services
import qs.apps.shared
import "settings.js" as St

PageFrame {
    id: page
    title: "Default apps"

    signal pickApplication(real x, real y, var items, var onPick)

    // Each role covers one or more MIME types; the first is read, all are set.
    readonly property var roles: [
        { label: "Web browser", mimes: ["x-scheme-handler/http", "x-scheme-handler/https", "text/html"] },
        { label: "Files and folders", mimes: ["inode/directory"] },
        { label: "Text editor", mimes: ["text/plain"] },
        { label: "Images", mimes: ["image/png", "image/jpeg"] },
        { label: "PDF documents", mimes: ["application/pdf"] }
    ]

    // role index -> { defaultId, registered }
    property var mimeState: ({})
    property string message: ""

    CommandRunner { id: runner }

    function load(i) {
        runner.runC(["gio", "mime", roles[i].mimes[0]], function (r) {
            var s = Object.assign({}, page.mimeState)
            s[i] = St.parseMime(r.out)
            page.mimeState = s
        })
    }

    function loadAll() { for (var i = 0; i < roles.length; i++) load(i) }

    function setDefault(i, desktopId) {
        var mimes = roles[i].mimes
        var remaining = mimes.length
        var failed = ""
        mimes.forEach(function (m) {
            runner.runC(["gio", "mime", m, desktopId], function (r) {
                if (r.code !== 0 && failed === "") failed = St.firstLine(r.err)
                if (--remaining === 0) {
                    page.message = failed === "" ? "" : "Could not change the default: " + failed
                    page.load(i)
                }
            })
        })
    }

    function nameOf(desktopId) {
        var e = desktopId ? ApplicationService.entryForAppId(St.entryId(desktopId)) : null
        return e ? e.name : (desktopId ? St.entryId(desktopId) : "None")
    }

    Component.onCompleted: loadAll()

    Text {
        width: parent.width
        wrapMode: Text.Wrap
        color: Theme.textSecondary
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontBody
        text: "The application that opens each kind of file or link. Changes apply to everything you open from Files, links and the launcher."
    }

    SettingsCard {
        Repeater {
            model: page.roles
            delegate: SettingRow {
                id: roleRow
                required property var modelData
                required property int index
                first: index === 0
                label: modelData.label
                description: page.mimeState[index] && page.mimeState[index].registered.length === 0 ? "No application is registered for this type" : ""

                AppIcon {
                    y: (parent.height - height) / 2
                    size: 22
                    source: {
                        var s = page.mimeState[roleRow.index]
                        var e = s && s.defaultId ? ApplicationService.entryForAppId(St.entryId(s.defaultId)) : null
                        return e ? ApplicationService.iconFor(e) : ""
                    }
                }
                Text {
                    y: (parent.height - height) / 2
                    text: page.mimeState[roleRow.index] ? page.nameOf(page.mimeState[roleRow.index].defaultId) : "…"
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontBody
                }
                AppButton {
                    id: change
                    text: "Change"
                    enabled: page.mimeState[roleRow.index] !== undefined && page.mimeState[roleRow.index].registered.length > 0
                    onClicked: {
                        var s = page.mimeState[roleRow.index]
                        var items = s.registered.map(function (id) {
                            return { text: page.nameOf(id) + (id === s.defaultId ? "  ✓" : ""), action: id }
                        })
                        var p = change.mapToItem(null, 0, change.height + 4)
                        page.pickApplication(p.x - 120, p.y, items, function (id) { page.setDefault(roleRow.index, id) })
                    }
                }
            }
        }
    }

    Text {
        width: parent.width
        visible: page.message.length > 0
        wrapMode: Text.Wrap
        color: Theme.orangeBright
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontCaption
        text: page.message
    }
}
