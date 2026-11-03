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
            color: Theme.surface

            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 1; color: Theme.borderSubtle }

            SearchField {
                id: searchBox
                anchors.left: parent.left
                anchors.leftMargin: Theme.spacingMd
                anchors.verticalCenter: parent.verticalCenter
                width: 320
                placeholder: root.appsView ? "Search applications" : "Search installed packages"
                accessibleName: "Search"
                debounce: 150
                onSearched: function (t) { backend.query = t }
                onEscaped: keyTarget.forceActiveFocus()
                onSubmitted: keyTarget.forceActiveFocus()
            }

            Text {
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
            color: Theme.surface

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
                            color: item.active ? Theme.cyanBright : Theme.textSecondary
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
                SideSection { label: "Installed packages" }
                SideItem { label: "All packages"; key: "all"; glyph: "archive"; count: String(backend.packages.length) }
                SideItem { label: "Chosen"; key: "explicit"; glyph: "download"; count: String(backend.explicitCount) }
                SideItem { label: "Dependencies"; key: "deps"; glyph: "code"; count: String(backend.packages.length - backend.explicitCount) }
                SideItem { label: "Unused dependencies"; key: "unused"; glyph: "broken-link"; count: String(backend.unusedCount) }
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
                color: Theme.orangeBright
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontCaption
            }
        }

        // ---- list ----
        ListView {
            id: list
            anchors.top: notice.bottom
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
                color: backend.error.length > 0 ? Theme.orangeBright : Theme.textSecondary
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
