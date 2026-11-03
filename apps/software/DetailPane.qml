import QtQuick
import Quickshell
import qs.src.shared
import qs.services
import qs.apps.shared
import "software.js" as Sw

// Details of the selected application or package. Everything shown is read
// from pacman or the desktop entry; the only actions are opening an
// application, opening a package's website, showing pacman output in a
// terminal, and jumping from an application to its package.
Rectangle {
    id: pane

    property var backend
    property var pkg: null          // parsed package, or null
    property var app: null          // DesktopEntry, or null
    property var files: null        // { count, files } for pkg
    property var appOwner: null     // { name, version } for app
    property bool ownerChecked: false

    signal showPackage(string name)

    color: Theme.surface

    Rectangle { anchors.left: parent.left; width: 1; height: parent.height; color: Theme.borderSubtle }

    onPkgChanged: files = null
    onAppChanged: {
        appOwner = null
        ownerChecked = false
        if (app) backend.owner(app, function (o) { pane.appOwner = o; pane.ownerChecked = true })
    }

    Flickable {
        anchors.fill: parent
        anchors.margins: Theme.spacingLg
        anchors.leftMargin: Theme.spacingLg + 1
        contentWidth: width
        contentHeight: col.height
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        Column {
            id: col
            width: parent.width
            spacing: Theme.spacingMd

            // ---- header ----
            Row {
                width: parent.width
                spacing: Theme.spacingMd

                AppIcon {
                    visible: pane.app !== null
                    size: 48
                    source: pane.app ? ApplicationService.iconFor(pane.app) : ""
                }

                Column {
                    width: parent.width - (pane.app ? 48 + Theme.spacingMd : 0)
                    spacing: 2
                    Text {
                        width: parent.width
                        text: pane.app ? (pane.app.name || "") : (pane.pkg ? pane.pkg.name : "")
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontDisplay
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }
                    Text {
                        width: parent.width
                        visible: text.length > 0
                        text: pane.app ? (pane.app.genericName || "") : (pane.pkg ? pane.pkg.version : "")
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontBody
                        elide: Text.ElideRight
                    }
                }
            }

            Text {
                width: parent.width
                text: pane.app ? (pane.app.comment || "") : (pane.pkg ? pane.pkg.description : "")
                visible: text.length > 0
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody
                wrapMode: Text.Wrap
            }

            // ---- actions ----
            Flow {
                width: parent.width
                spacing: Theme.spacingSm

                AppButton {
                    visible: pane.app !== null
                    text: "Open"
                    primary: true
                    onClicked: ApplicationService.launch(pane.app)
                }
                AppButton {
                    visible: pane.app !== null && pane.appOwner !== null
                    text: "Show package"
                    onClicked: pane.showPackage(pane.appOwner.name)
                }
                AppButton {
                    visible: pane.pkg !== null && pane.pkg.url.length > 0
                    text: "Open website"
                    onClicked: Quickshell.execDetached(["gio", "open", pane.pkg.url])
                }
                AppButton {
                    visible: pane.pkg !== null
                    text: "Show in terminal"
                    onClicked: TerminalService.open("", "pacman -Qi " + pane.pkg.name, ["pacman", "-Qi", pane.pkg.name])
                }
            }

            Rectangle { width: parent.width; height: 1; color: Theme.borderSubtle }

            // ---- application facts ----
            InfoRow { label: "Desktop entry"; value: pane.app ? pane.app.id + ".desktop" : ""; mono: true }
            InfoRow { label: "Command"; value: pane.app && pane.app.command ? pane.app.command.join(" ") : ""; mono: true }
            InfoRow { label: "Categories"; value: pane.app && pane.app.categories ? pane.app.categories.join(", ") : "" }
            InfoRow {
                label: "Package"
                value: !pane.app ? "" : (pane.appOwner ? pane.appOwner.name + " " + pane.appOwner.version
                                         : (pane.ownerChecked ? "Not from a package (part of the Axiom image)" : "Checking…"))
            }

            // ---- package facts ----
            InfoRow { label: "Installed size"; value: pane.pkg ? pane.pkg.installedSize : "" }
            InfoRow { label: "Installed"; value: pane.pkg ? pane.pkg.installDate : "" }
            InfoRow { label: "Reason"; value: pane.pkg ? (pane.pkg.explicit ? "Chosen by you or the image" : "Needed by another package") : "" }
            InfoRow { label: "Licenses"; value: pane.pkg ? pane.pkg.licenses.join(", ") : "" }
            InfoRow { label: "Architecture"; value: pane.pkg ? pane.pkg.architecture : "" }
            InfoRow { label: "Packager"; value: pane.pkg ? pane.pkg.packager : "" }
            InfoRow { label: "Built"; value: pane.pkg ? pane.pkg.buildDate : "" }
            InfoRow { label: "Website"; value: pane.pkg ? pane.pkg.url : "" }
            InfoRow { label: "Groups"; value: pane.pkg ? pane.pkg.groups.join(", ") : "" }
            InfoRow { label: "Provides"; value: pane.pkg ? pane.pkg.provides.join(", ") : "" }
            InfoRow { label: "Depends on"; value: pane.pkg ? pane.pkg.depends.join(", ") : "" }
            InfoRow { label: "Required by"; value: pane.pkg ? pane.pkg.requiredBy.join(", ") : "" }
            InfoRow { label: "Optional deps"; value: pane.pkg ? pane.pkg.optionalDeps.join("\n") : "" }
            InfoRow { label: "Conflicts with"; value: pane.pkg ? pane.pkg.conflicts.join(", ") : "" }

            // ---- files ----
            Column {
                visible: pane.pkg !== null
                width: parent.width
                spacing: Theme.spacingSm

                AppButton {
                    visible: pane.files === null
                    text: "Show installed files"
                    onClicked: pane.backend.packageFiles(pane.pkg.name, function (f) { pane.files = f })
                }

                Text {
                    visible: pane.files !== null
                    width: parent.width
                    text: pane.files ? (pane.files.error ? pane.files.error
                          : pane.files.count + (pane.files.count === 1 ? " file" : " files")
                            + (pane.files.count > pane.files.files.length ? " (first " + pane.files.files.length + " shown)" : "")) : ""
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontCaption
                }

                Text {
                    visible: pane.files !== null && !pane.files.error
                    width: parent.width
                    text: pane.files ? pane.files.files.join("\n") : ""
                    color: Theme.textPrimary
                    font.family: Theme.fontFamilyMono
                    font.pixelSize: Theme.fontCaption
                    wrapMode: Text.WrapAnywhere
                }
            }

            Text {
                width: parent.width
                text: "Installing, removing and updating packages isn't available yet. It needs Axiom's permission layer, so this app only shows what is installed."
                color: Theme.textDisabled
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontCaption
                wrapMode: Text.Wrap
            }
        }
    }
}
