import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.src.shared
import qs.services

// Axiom application launcher. Searches real XDG desktop entries, keyboard
// first, and launches through ApplicationService. Two presentations of the
// same results: "search" (list; panel search icon, Super+D) and "grid" (Apps;
// panel "Apps", dock Axiom mark).
PanelWindow {
    id: launcher

    screen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: UiState.launcherOpen
    WlrLayershell.namespace: "axiom-launcher"
    WlrLayershell.layer: WlrLayershell.Overlay
    // No `focusable:` here: it makes Quickshell request on-demand keyboard
    // interactivity and overrides the explicit Exclusive mode below, so the
    // compositor hands the keyboard straight back to the app and Escape never
    // reaches this overlay.
    WlrLayershell.keyboardFocus: UiState.launcherOpen ? WlrLayershell.Exclusive : WlrLayershell.None

    readonly property var results: ApplicationService.search(UiState.launcherQuery)
    property int selected: 0
    readonly property bool gridMode: UiState.launcherMode === "grid"
    readonly property int gridColumns: 5
    readonly property int rowsPerPage: 3
    readonly property int perPage: gridColumns * rowsPerPage
    readonly property int pageCount: Math.max(1, Math.ceil(results.length / perPage))
    readonly property int currentPage: Math.floor(selected / perPage)

    function move(delta) {
        var n = results.length
        if (n === 0) return
        selected = Math.max(0, Math.min(n - 1, selected + delta))
    }

    function launchSelected() {
        var entry = results[selected]
        if (entry) ApplicationService.launch(entry)
        UiState.closeAllOverlays()
    }

    onVisibleChanged: {
        if (visible) {
            selected = 0
            pages.positionViewAtBeginning()
            searchField.forceActiveFocus()
        }
    }

    // Click outside the card closes the launcher. Escape is handled by the
    // focused TextInput.
    MouseArea {
        anchors.fill: parent
        onClicked: UiState.closeAllOverlays()
    }

    GlassSurface {
        id: card
        width: launcher.gridMode ? Math.min(860, launcher.width - 96) : Math.min(560, launcher.width - 96)
        height: launcher.gridMode ? Math.min(600, launcher.height - 180) : Math.min(460, launcher.height - 180)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Math.max(Theme.panelBottom + 24, Math.round(launcher.height * 0.12))
        radius: Theme.radiusWindow
        strong: true

        MouseArea { anchors.fill: parent }

        Column {
            anchors.fill: parent
            anchors.margins: Theme.spacingMd
            spacing: Theme.spacingSm

            // Search pill (reference launcher): small, centred, rounded, cyan edge on focus.
            Item {
            width: parent.width
            height: 40
            Rectangle {
                id: pill
                width: 360
                height: 40
                anchors.horizontalCenter: parent.horizontalCenter
                radius: height / 2
                color: Theme.stateHover
                border.width: 1
                border.color: searchField.activeFocus ? Theme.stateSelectedBorder : Theme.borderSubtle

                AxiomIcon {
                    id: pillIcon
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.spacingMd
                    anchors.verticalCenter: parent.verticalCenter
                    width: 16
                    height: 16
                    name: "search"
                    color: Theme.textSecondary
                }

            TextInput {
                id: searchField
                anchors.left: pillIcon.right
                anchors.leftMargin: Theme.spacingSm
                anchors.right: parent.right
                anchors.rightMargin: Theme.spacingMd
                anchors.verticalCenter: parent.verticalCenter
                height: parent.height
                color: Theme.foreground
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody + 2
                verticalAlignment: TextInput.AlignVCenter
                focus: launcher.visible
                onTextChanged: {
                    UiState.launcherQuery = text
                    launcher.selected = 0
                }
                onAccepted: launcher.launchSelected()

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    visible: searchField.text.length === 0
                    text: launcher.gridMode ? "Applications \u00b7 type to search" : "Search applications"
                    color: Theme.muted
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontBody + 2
                }

                Keys.onEscapePressed: UiState.closeAllOverlays()
                Keys.onDownPressed: launcher.move(launcher.gridMode ? launcher.gridColumns : 1)
                Keys.onUpPressed: launcher.move(launcher.gridMode ? -launcher.gridColumns : -1)
                Keys.onPressed: function (event) {
                    if (!launcher.gridMode) return
                    if (event.key === Qt.Key_Right) { launcher.move(1); event.accepted = true }
                    else if (event.key === Qt.Key_Left) { launcher.move(-1); event.accepted = true }
                }
            }
            }
            }

            // Carousel (grid mode): pages of 5 x 3 tiles. Swipe, arrow keys or the dots.
            ListView {
                id: pages
                visible: launcher.gridMode
                width: parent.width
                height: parent.height - 40 - Theme.spacingSm - 18
                clip: true
                orientation: ListView.Horizontal
                snapMode: ListView.SnapOneItem
                highlightRangeMode: ListView.StrictlyEnforceRange
                boundsBehavior: Flickable.StopAtBounds
                model: launcher.gridMode ? launcher.pageCount : 0
                currentIndex: launcher.currentPage

                delegate: Item {
                    id: pageItem
                    required property int index
                    width: pages.width
                    height: pages.height

                    Grid {
                        id: pageGrid
                        readonly property int first: pageItem.index * launcher.perPage
                        columns: launcher.gridColumns
                        anchors.fill: parent

                        Repeater {
                            model: launcher.results.slice(pageGrid.first, pageGrid.first + launcher.perPage)

                            delegate: Item {
                                id: tile
                                required property var modelData
                                required property int index
                                readonly property int absolute: pageGrid.first + index
                                width: pages.width / launcher.gridColumns
                                height: pages.height / launcher.rowsPerPage

                                Rectangle {
                                    anchors.fill: parent
                                    anchors.margins: 4
                                    radius: Theme.radiusSurface
                                    color: tile.absolute === launcher.selected ? Theme.stateSelected
                                         : tileMouse.containsMouse ? Theme.stateHover : "transparent"
                                    border.width: tile.absolute === launcher.selected ? 1 : 0
                                    border.color: Theme.stateSelectedBorder
                                }

                                AppIcon {
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    anchors.top: parent.top
                                    anchors.topMargin: 14
                                    size: 64
                                    source: ApplicationService.iconFor(tile.modelData)
                                }

                                Text {
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    anchors.bottom: parent.bottom
                                    anchors.margins: 8
                                    horizontalAlignment: Text.AlignHCenter
                                    elide: Text.ElideRight
                                    text: tile.modelData.name
                                    color: Theme.textPrimary
                                    font.family: Theme.fontFamily
                                    font.pixelSize: Theme.fontCaption
                                }

                                MouseArea {
                                    id: tileMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    onEntered: launcher.selected = tile.absolute
                                    onClicked: {
                                        launcher.selected = tile.absolute
                                        launcher.launchSelected()
                                    }
                                }
                            }
                        }
                    }
                }
            }

            ListView {
                id: list
                visible: !launcher.gridMode
                width: parent.width
                height: parent.height - 40 - Theme.spacingSm
                clip: true
                model: launcher.gridMode ? [] : launcher.results
                currentIndex: launcher.selected
                boundsBehavior: Flickable.StopAtBounds

                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    width: list.width
                    height: 44
                    radius: Theme.radiusControl
                    color: index === launcher.selected ? Theme.stateSelected : "transparent"
                    border.width: index === launcher.selected ? 1 : 0
                    border.color: Theme.stateSelectedBorder

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.spacingSm
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.spacingSm
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: Theme.spacingSm

                        AppIcon {
                            anchors.verticalCenter: parent.verticalCenter
                            size: 26
                            source: ApplicationService.iconFor(modelData)
                        }

                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.name
                            color: index === launcher.selected ? Theme.textPrimary : Theme.textSecondary
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontBody
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered: launcher.selected = index
                        onClicked: {
                            launcher.selected = index
                            launcher.launchSelected()
                        }
                    }
                }
            }

            // Pager (grid mode): one dot per page of cells, current page lit.
            Row {
                visible: launcher.gridMode && launcher.results.length > 0
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 6
                Repeater {
                    model: launcher.pageCount
                    delegate: Rectangle {
                        required property int index
                        width: 6; height: 6; radius: 3
                        color: index === launcher.currentPage ? Theme.textPrimary : Theme.textDisabled
                    }
                }
            }

            Text {
                width: parent.width
                visible: launcher.results.length === 0
                text: "No matching applications"
                horizontalAlignment: Text.AlignHCenter
                color: Theme.muted
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody
            }
        }
    }
}
