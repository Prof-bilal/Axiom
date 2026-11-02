import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import qs.src.shared
import qs.services

// One notification. Untrusted content is rendered as plain text only.
Rectangle {
    id: card
    property var notification
    property bool toast: false

    implicitHeight: content.implicitHeight + Theme.spacingMd * 2
    radius: Theme.radiusSurface
    color: Theme.overlayBackground
    border.width: 1
    border.color: notification && notification.urgency === NotificationUrgency.Critical
        ? Theme.danger : Theme.border

    Timer {
        running: card.toast && card.notification
        interval: card.notification
            ? Math.max(5000, card.notification.expireTimeout * 1000) : 5000
        onTriggered: if (card.notification) card.notification.expire()
    }

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        spacing: Theme.spacingXs

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSm

            Image {
                visible: card.notification && card.notification.appIcon
                source: card.notification
                    ? Quickshell.iconPath(card.notification.appIcon, "application-x-executable") : ""
                sourceSize.width: 18
                sourceSize.height: 18
                Layout.preferredWidth: 18
                Layout.preferredHeight: 18
                fillMode: Image.PreserveAspectFit
            }

            Text {
                Layout.fillWidth: true
                text: card.notification ? (card.notification.appName || "Application") : ""
                color: Theme.muted
                elide: Text.ElideRight
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontCaption
            }

            Text {
                text: "\u2715"
                color: hoverClose.hovered ? Theme.danger : Theme.muted
                font.pixelSize: Theme.fontCaption
                HoverHandler { id: hoverClose }
                MouseArea {
                    anchors.fill: parent
                    anchors.margins: -Theme.spacingXs
                    onClicked: if (card.notification) card.notification.dismiss()
                }
            }
        }

        Text {
            Layout.fillWidth: true
            text: card.notification ? card.notification.summary : ""
            color: Theme.foreground
            wrapMode: Text.WordWrap
            textFormat: Text.PlainText
            font.family: Theme.fontFamily
            font.pixelSize: Theme.fontBody
            font.weight: Font.DemiBold
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

        RowLayout {
            Layout.fillWidth: true
            visible: card.notification && card.notification.actions.length > 0
            spacing: Theme.spacingSm

            Repeater {
                model: card.notification ? card.notification.actions : []

                Rectangle {
                    required property var modelData
                    implicitWidth: actionLabel.implicitWidth + Theme.spacingMd * 2
                    implicitHeight: 26
                    radius: Theme.radiusControl
                    color: actionHover.hovered ? Theme.accentDeep : Theme.surfaceHigh

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

            Item { Layout.fillWidth: true }
        }
    }
}
