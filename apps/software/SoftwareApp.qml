import QtQuick
import Quickshell
import qs.src.shared
import qs.services
import qs.apps.shared
import "software.js" as Sw

// Axiom Software: browse the applications and packages installed on this
// system, with details. Read-only: package changes need the permission layer
// that arrives in a later phase, and repository data needs a database refresh
// (also privileged); the window says so instead of pretending.
AppWindow {
    id: root

    title: "Software"
    implicitWidth: 1120
    implicitHeight: 680

    PackageBackend { id: backend }

    // The selection survives filtering: remember the key, not the row.
    property string selectedKey: ""
    readonly property bool appsView: backend.view === "apps"
    readonly property var rows: appsView ? backend.visibleApps : backend.visiblePackages
    readonly property var selectedPackage: {
        if (appsView || selectedKey.length === 0) return null
        for (var i = 0; i < backend.packages.length; i++)
            if (backend.packages[i].name === selectedKey) return backend.packages[i]
        return null
    }
    readonly property var selectedApp: {
        if (!appsView || selectedKey.length === 0) return null
        for (var i = 0; i < backend.visibleApps.length; i++)
            if (backend.visibleApps[i].id === selectedKey) return backend.visibleApps[i]
        return null
    }

    function setView(v) {
        backend.view = v
        selectedKey = ""
        list.positionViewAtBeginning()
    }

    function showPackage(name) {
        searchBox.clear()
        backend.query = ""
        backend.view = "all"
        selectedKey = name
        for (var i = 0; i < backend.visiblePackages.length; i++)
            if (backend.visiblePackages[i].name === name) { list.positionViewAtIndex(i, ListView.Center); break }
    }

    FocusScope {
        id: main
        anchors.fill: parent
        focus: true

        Item { id: keyTarget; focus: true }

        Keys.onPressed: function (event) {
            var ctrl = (event.modifiers & Qt.ControlModifier) !== 0
            event.accepted = true
            if (ctrl && event.key === Qt.Key_F) searchBox.focusInput()
            else if (event.key === Qt.Key_Down || event.key === Qt.Key_Up) {
                var n = root.rows.length
                if (n === 0) return
                var cur = -1
                for (var i = 0; i < n; i++) {
                    var k = root.appsView ? root.rows[i].id : root.rows[i].name
                    if (k === root.selectedKey) { cur = i; break }
                }
                var next = Math.max(0, Math.min(n - 1, cur + (event.key === Qt.Key_Down ? 1 : -1)))
                root.selectedKey = root.appsView ? root.rows[next].id : root.rows[next].name
                list.positionViewAtIndex(next, ListView.Contain)
            }
            else if (event.key === Qt.Key_Return && root.selectedApp) ApplicationService.launch(root.selectedApp)
            else if (event.key === Qt.Key_Escape) { root.selectedKey = "" }
            else event.accepted = false
        }

        // ---- toolbar ----
        Rectangle {
            id: toolbar
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 48
            color: "transparent"

            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.borderSubtle }

            SearchField {
                id: searchBox
                anchors.left: parent.left
                anchors.leftMargin: Theme.spacingMd
                anchors.verticalCenter: parent.verticalCenter
                width: 320
                placeholder: root.appsView ? "Search applications" : backend.view === "find" ? "Search repositories (for example htop)" : "Search installed packages"
                accessibleName: "Search"
                debounce: 150
                onSearched: function (t) { backend.query = t }
                onEscaped: keyTarget.forceActiveFocus()
                onSubmitted: keyTarget.forceActiveFocus()
            }

            Text {
                id: countText
                anchors.right: parent.right
                anchors.rightMargin: Theme.spacingLg
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontCaption
                text: backend.loading ? "Reading the package database…"
                      : root.rows.length + (root.appsView ? (root.rows.length === 1 ? " application" : " applications")
                                                            : (root.rows.length === 1 ? " package" : " packages"))
            }
        }

        // ---- sidebar ----
        Rectangle {
            id: sidebar
            anchors.top: toolbar.bottom
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            width: 236
            color: "transparent"

            Rectangle { anchors.right: parent.right; width: 1; height: parent.height; color: Theme.borderSubtle }

            Column {
                anchors.fill: parent
                anchors.margins: Theme.spacingSm
                anchors.topMargin: Theme.spacingMd
                spacing: 2

                component SideSection: Item {
                    property string label: ""
                    width: parent.width
                    height: 30
                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacingMd
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 4
                        text: parent.label.toUpperCase()
                        color: Theme.textDisabled
                        font.family: Theme.fontFamily
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        font.letterSpacing: 0.8
                    }
                }

                component SideItem: Rectangle {
                    id: item
                    property string label: ""
                    property string key: ""
                    property string count: ""
                    property string glyph: "archive"
                    readonly property bool active: backend.view === key
                    width: parent.width
                    height: 32
                    radius: Theme.radiusControl
                    color: active ? Theme.stateSelected : (hit.containsMouse ? Theme.stateHover : "transparent")
                    border.width: active ? 1 : 0
                    border.color: Theme.stateSelectedBorder
                    Accessible.role: Accessible.Button
                    Accessible.name: label

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacingMd
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.spacingMd
                        AxiomIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            width: 18
                            height: 18
                            name: item.glyph
                            color: item.active ? Theme.accentBright : Theme.textSecondary
                            strokeWidth: 1.5
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: item.label
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontBody
                            font.weight: item.active ? Font.Medium : Font.Normal
                        }
                    }
                    Text {
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.spacingMd
                        anchors.verticalCenter: parent.verticalCenter
                        text: item.count
                        color: Theme.textSecondary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontCaption
                    }
                    MouseArea {
                        id: hit
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.setView(item.key)
                    }
                }

                SideSection { label: "Discover" }
                SideItem { label: "Applications"; key: "apps"; glyph: "application"; count: backend.visibleApps.length > 0 || backend.query.length === 0 ? String(ApplicationService.all.filter(function (e) { return !e.noDisplay }).length) : "" }
                SideItem { label: "Find packages"; key: "find"; glyph: "archive"; count: String(backend.repoResults.length) }
                SideItem { label: "Updates"; key: "updates"; glyph: "refresh"; count: String(backend.updates.length) }
                SideItem { label: "Flatpak apps"; key: "flatpak"; glyph: "archive"; count: String(backend.flatpaks.length) }
                SideItem { label: "Snapshots"; key: "snapshots"; glyph: "refresh"; count: String(backend.snapshots.length) }
                SideSection { label: "Installed packages" }
                SideItem { label: "All packages"; key: "all"; glyph: "archive"; count: String(backend.packages.length) }
                SideItem { label: "Chosen"; key: "explicit"; glyph: "download"; count: String(backend.explicitCount) }
                SideItem { label: "Dependencies"; key: "deps"; glyph: "code"; count: String(backend.packages.length - backend.explicitCount) }
                SideItem { label: "Unused dependencies"; key: "unused"; glyph: "broken-link"; count: String(backend.unusedCount) }
            }
        }

        // ---- find packages in the repositories: install or remove through the helper (polkit prompt) ----
        Rectangle {
            id: findPanel
            anchors.top: toolbar.bottom
            anchors.left: sidebar.right
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            visible: backend.view === "find"
            color: "transparent"

            Text {
                id: findMsg
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: Theme.spacingLg
                text: backend.repoMessage.length > 0 ? backend.repoMessage
                      : "Search the repositories with the box above. Installing and removing ask for admin approval."
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontCaption
            }

            ListView {
                anchors.top: findMsg.bottom
                anchors.topMargin: Theme.spacingSm
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: Theme.spacingLg
                clip: true
                model: backend.repoResults
                delegate: Item {
                    required property var modelData
                    width: ListView.view.width
                    height: 56

                    Column {
                        anchors.left: parent.left
                        anchors.right: actionButton.left
                        anchors.rightMargin: Theme.spacingLg
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        Text {
                            width: parent.width
                            elide: Text.ElideRight
                            text: modelData.name + "  " + modelData.version + "  (" + modelData.repo + ")"
                            color: Theme.textPrimary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontBody
                        }
                        Text {
                            width: parent.width
                            elide: Text.ElideRight
                            text: modelData.desc
                            color: Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontCaption
                        }
                    }
                    AppButton {
                        id: actionButton
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: modelData.installed ? "Remove" : "Install"
                        primary: !modelData.installed
                        destructive: modelData.installed
                        enabled: !backend.repoBusy
                        onClicked: modelData.installed ? backend.removePackage(modelData.name)
                                                       : backend.installPackage(modelData.name)
                    }
                }
            }
        }

        // ---- snapshots and rollback (ADR-033): rolling back needs a second click to confirm ----
        Rectangle {
            id: snapPanel
            anchors.top: toolbar.bottom
            anchors.left: sidebar.right
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            visible: backend.view === "snapshots"
            color: "transparent"

            Text {
                id: snapNote
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: Theme.spacingLg
                width: parent.width - 2 * Theme.spacingLg
                wrapMode: Text.Wrap
                text: backend.snapshotMessage.length > 0 ? backend.snapshotMessage
                      : "Rolling back returns the system to that snapshot. Restart afterwards. Your files in /home are kept."
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontCaption
            }
            ListView {
                anchors.top: snapNote.bottom
                anchors.topMargin: Theme.spacingLg
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                clip: true
                model: backend.snapshots
                delegate: Rectangle {
                    required property var modelData
                    width: ListView.view.width
                    height: 52
                    color: "transparent"
                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacingLg
                        anchors.verticalCenter: parent.verticalCenter
                        Text { text: modelData.description || "Snapshot " + modelData.number; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontBody; font.weight: Font.Medium }
                        Text { text: "#" + modelData.number + "  ·  " + modelData.date; color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontCaption }
                    }
                    AppButton {
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.spacingLg
                        anchors.verticalCenter: parent.verticalCenter
                        text: backend.pendingRollback === modelData.number ? "Confirm roll back" : "Roll back"
                        destructive: backend.pendingRollback === modelData.number
                        onClicked: backend.pendingRollback === modelData.number ? backend.confirmRollback(modelData.number) : backend.askRollback(modelData.number)
                    }
                }
            }
        }

        // ---- Flatpak apps (ADR-034): list, update, remove, and install from Flathub ----
        Rectangle {
            id: flatpakPanel
            anchors.top: toolbar.bottom
            anchors.left: sidebar.right
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            visible: backend.view === "flatpak"
            color: "transparent"

            Row {
                id: flatpakInstallRow
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.margins: Theme.spacingLg
                spacing: Theme.spacingSm
                Rectangle {
                    width: 300
                    height: 32
                    radius: 16
                    color: Theme.stateHover
                    border.width: 1
                    border.color: flatpakId.activeFocus ? Theme.stateSelectedBorder : Theme.borderSubtle
                    TextInput {
                        id: flatpakId
                        anchors.fill: parent
                        anchors.leftMargin: Theme.spacingMd
                        anchors.rightMargin: Theme.spacingMd
                        verticalAlignment: TextInput.AlignVCenter
                        clip: true
                        color: Theme.textPrimary
                        font.family: Theme.fontFamily
                        font.pixelSize: Theme.fontCaption
                        onAccepted: backend.flatpakInstall(text.trim())
                    }
                }
                AppButton { text: "Install from Flathub"; primary: true; onClicked: backend.flatpakInstall(flatpakId.text.trim()) }
            }
            Text {
                anchors.top: flatpakInstallRow.bottom
                anchors.left: parent.left
                anchors.margins: Theme.spacingLg
                text: backend.flatpakMessage
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontCaption
            }
            ListView {
                anchors.top: flatpakInstallRow.bottom
                anchors.topMargin: Theme.spacingXl
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                clip: true
                model: backend.flatpaks
                delegate: Rectangle {
                    required property var modelData
                    width: ListView.view.width
                    height: 52
                    color: "transparent"
                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacingLg
                        anchors.verticalCenter: parent.verticalCenter
                        Text { text: modelData.name; color: Theme.textPrimary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontBody; font.weight: Font.Medium }
                        Text { text: modelData.id + (modelData.version ? "  ·  " + modelData.version : ""); color: Theme.textSecondary; font.family: Theme.fontFamily; font.pixelSize: Theme.fontCaption }
                    }
                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.spacingLg
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.spacingSm
                        AppButton { text: "Update"; onClicked: backend.flatpakUpdate(modelData.id) }
                        AppButton { text: "Remove"; destructive: true; onClicked: backend.flatpakRemove(modelData.id) }
                    }
                }
            }
        }

        // ---- updates (ADR-033): one admin approval updates the system, after a snapshot ----
        Rectangle {
            id: updateBar
            anchors.top: toolbar.bottom
            anchors.left: sidebar.right
            anchors.right: parent.right
            height: visible ? 64 : 0
            visible: backend.view === "updates"
            color: "transparent"
            Column {
                anchors.left: parent.left
                anchors.leftMargin: Theme.spacingLg
                anchors.verticalCenter: parent.verticalCenter
                spacing: 4
                Text {
                    text: backend.updates.length === 0 ? "The system is up to date."
                          : backend.updates.length + (backend.updates.length === 1 ? " update available" : " updates available")
                    color: Theme.textPrimary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontBody
                    font.weight: Font.DemiBold
                }
                Text {
                    text: backend.snapshotsAvailable ? "A snapshot is taken first, so you can roll back."
                          : "Updates need snapshots (btrfs with snapper). This system has none, so updates are off."
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontCaption
                }
                Text {
                    visible: backend.updateMessage.length > 0
                    text: backend.updateMessage
                    color: Theme.textSecondary
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontCaption
                }
            }
            AppButton {
                anchors.right: parent.right
                anchors.rightMargin: Theme.spacingLg
                anchors.verticalCenter: parent.verticalCenter
                text: "Update all"
                primary: true
                enabled: backend.snapshotsAvailable && backend.updates.length > 0
                onClicked: backend.updateAll()
            }
        }

        // ---- notice about offline data ----
        Rectangle {
            id: notice
            anchors.top: toolbar.bottom
            anchors.left: sidebar.right
            anchors.right: detail.visible ? detail.left : parent.right
            height: visible ? 34 : 0
            visible: backend.checkedDatabases && !backend.hasDatabases
            color: Theme.stateUrgentWash

            Text {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacingLg
                anchors.rightMargin: Theme.spacingLg
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                text: "No repository data is available offline, so only installed software is shown."
                color: Theme.dangerBright
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontCaption
            }
        }

        // ---- list ----
        ListView {
            id: list
            visible: backend.view !== "updates" && backend.view !== "flatpak" && backend.view !== "snapshots" && backend.view !== "find"
            anchors.top: updateBar.visible ? updateBar.bottom : notice.bottom
            anchors.bottom: parent.bottom
            anchors.left: sidebar.right
            anchors.right: detail.visible ? detail.left : parent.right
            anchors.margins: Theme.spacingSm
            clip: true
            // Integer model: handing a large JS array to the view converts every
            // object; rows look their data up by index (see Files).
            model: root.rows.length
            boundsBehavior: Flickable.StopAtBounds
            reuseItems: true

            delegate: PackageRow {
                required property int index
                readonly property var item: root.rows[index]
                width: ListView.view.width
                title: item ? item.name : ""
                subtitle: item ? (root.appsView ? (item.comment || item.genericName || "") : item.description) : ""
                facts: item && !root.appsView ? item.version + "  ·  " + item.installedSize : ""
                iconSource: item && root.appsView ? ApplicationService.iconFor(item) : ""
                glyph: "archive"
                selected: item !== undefined && (root.appsView ? item.id : item.name) === root.selectedKey
                onActivated: { root.selectedKey = root.appsView ? item.id : item.name; keyTarget.forceActiveFocus() }
            }

            Text {
                anchors.centerIn: parent
                width: parent.width - Theme.spacingXl * 2
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                visible: text.length > 0
                color: backend.error.length > 0 ? Theme.dangerBright : Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontLabel
                text: backend.error.length > 0 ? backend.error
                      : (backend.loading && !root.appsView) ? "Reading the package database…"
                      : root.rows.length === 0 ? (backend.query.length > 0 ? "No results for “" + backend.query + "”"
                                                  : (backend.view === "unused" ? "No unused dependencies" : "Nothing to show here"))
                      : ""
            }
        }

        // ---- details ----
        DetailPane {
            id: detail
            anchors.top: toolbar.bottom
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            width: 400
            visible: root.selectedKey.length > 0 && (root.selectedPackage !== null || root.selectedApp !== null)
            backend: backend
            pkg: root.selectedPackage
            app: root.selectedApp
            onShowPackage: function (name) { root.showPackage(name) }
        }
    }

}
