import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import qs.src.shared
import qs.services

// One notification, in the reference style: a rounded icon tile, a bold title,
// muted body text and pill action buttons, on a solid card.
// Untrusted content is rendered as plain text only.
SolidSurface {
    id: card
    property var notification
    property bool toast: false
    readonly property bool critical: notification && notification.urgency === NotificationUrgency.Critical

    implicitHeight: content.implicitHeight + Theme.spacingMd * 2
    radius: Theme.radiusWindow

    // Critical notifications keep an orange outline over the card edge.
    Rectangle {
        anchors.fill: parent
        radius: card.radius
        color: "transparent"
        border.width: 1
        border.color: Theme.danger
        visible: card.critical
    }

    Timer {
        running: card.toast && card.notification
        interval: card.notification
            ? Math.max(5000, card.notification.expireTimeout * 1000) : 5000
        onTriggered: if (card.notification) card.notification.expire()
    }

    RowLayout {
        id: content
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        spacing: Theme.spacingMd

        // Icon tile: the app's icon, or the Axiom mascot for toasts.
        Rectangle {
            Layout.alignment: Qt.AlignTop
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            radius: 10
            color: card.critical ? Theme.danger : Theme.accentMuted

            Image {
                anchors.centerIn: parent
                width: 24
                height: 24
                source: card.notification && card.notification.appIcon
                    ? Quickshell.iconPath(card.notification.appIcon, "application-x-executable")
                    : Quickshell.shellPath("assets/mascots/notification.png")
                sourceSize.width: 48
                sourceSize.height: 48
                fillMode: Image.PreserveAspectFit
                smooth: true
                mipmap: true
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSm

                Text {
                    Layout.fillWidth: true
                    text: card.notification ? card.notification.summary : ""
                    color: Theme.foreground
                    wrapMode: Text.WordWrap
                    textFormat: Text.PlainText
                    font.family: Theme.fontFamily
                    font.pixelSize: Theme.fontLabel
                    font.weight: Font.DemiBold
                }

                // Dismiss: a small close mark, visible on hover.
                Text {
                    text: "✕"
                    visible: closeHover.hovered
                    color: Theme.muted
                    font.pixelSize: Theme.fontCaption
                    HoverHandler { id: closeHover }
                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -Theme.spacingXs
                        onClicked: if (card.notification) card.notification.dismiss()
                    }
                }
            }

            Text {
                Layout.fillWidth: true
                visible: card.notification && card.notification.body.length > 0
                text: card.notification ? card.notification.body : ""
                color: Theme.muted
                wrapMode: Text.WordWrap
                maximumLineCount: 4
                elide: Text.ElideRight
                textFormat: Text.PlainText
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody
            }

            // Pill buttons, as in the reference: one row, centred on the card.
            Flow {
                Layout.fillWidth: true
                Layout.topMargin: Theme.spacingXs
                spacing: Theme.spacingSm
                visible: card.notification && card.notification.actions.length > 0

                Repeater {
                    model: card.notification ? card.notification.actions : []

                    Rectangle {
                        required property var modelData
                        implicitWidth: actionLabel.implicitWidth + Theme.spacingLg * 2
                        implicitHeight: 28
                        radius: height / 2
                        color: actionHover.hovered ? Theme.stateHover : Theme.cardFill
                        border.width: 1
                        border.color: Theme.borderSubtle

                        HoverHandler { id: actionHover }

                        Text {
                            id: actionLabel
                            anchors.centerIn: parent
                            text: modelData.text
                            color: Theme.foreground
                            font.family: Theme.fontFamily
                            font.pixelSize: Theme.fontCaption
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: modelData.invoke()
                        }
                    }
                }
            }
        }
    }
}
