import QtQuick
import Quickshell.Services.Pipewire
import qs.src.shared
import qs.services
import qs.apps.shared

PageFrame {
    id: page
    title: "Sound"

    // Audio nodes only: devices (sinks / sources) and the apps playing or recording.
    readonly property var nodes: Pipewire.nodes ? Pipewire.nodes.values : []
    readonly property var sinks: nodes.filter(function (n) { return n.audio && n.isSink && !n.isStream })
    readonly property var sources: nodes.filter(function (n) { return n.audio && !n.isSink && !n.isStream && n.description !== undefined && !/monitor/i.test(n.name) })
    readonly property var streams: nodes.filter(function (n) { return n.audio && n.isStream })

    PwObjectTracker { objects: page.nodes.filter(function (n) { return n.audio }) }

    Notice {
        visible: !Pipewire.ready || (page.sinks.length === 0 && page.sources.length === 0)
        warning: true
        text: !Pipewire.ready ? "The audio service (PipeWire) is not running." : "No audio devices were found."
    }

    SettingsCard {
        title: "Output"
        visible: page.sinks.length > 0
        Repeater {
            model: page.sinks
            delegate: DeviceRow { required property var modelData; required property int index; node: modelData; first: index === 0; defaultNode: Pipewire.defaultAudioSink; onMakeDefault: Pipewire.preferredDefaultAudioSink = modelData }
        }
    }

    SettingsCard {
        title: "Input"
        visible: page.sources.length > 0
        Repeater {
            model: page.sources
            delegate: DeviceRow { required property var modelData; required property int index; node: modelData; first: index === 0; defaultNode: Pipewire.defaultAudioSource; onMakeDefault: Pipewire.preferredDefaultAudioSource = modelData }
        }
    }

    SettingsCard {
        title: "Applications"
        visible: page.streams.length > 0
        Repeater {
            model: page.streams
            delegate: DeviceRow { required property var modelData; required property int index; node: modelData; first: index === 0; defaultNode: null; stream: true }
        }
    }

    component DeviceRow: SettingRow {
        id: row
        property var node: null
        property var defaultNode: null
        property bool stream: false
        signal makeDefault()
        label: node ? (node.nickname || node.description || node.name) : ""
        description: row.stream ? "" : (node && defaultNode && node.id === defaultNode.id ? "Default" : "")

        SliderControl {
            width: 150
            anchors.verticalCenter: parent.verticalCenter
            accessibleName: row.label + " volume"
            value: row.node && row.node.audio ? row.node.audio.volume * 100 : 0
            onMoved: function (p) { if (row.node && row.node.audio) row.node.audio.volume = p / 100 }
        }
        AppButton {
            text: row.node && row.node.audio && row.node.audio.muted ? "Unmute" : "Mute"
            onClicked: row.node.audio.muted = !row.node.audio.muted
        }
        AppButton {
            visible: !row.stream && !(row.node && row.defaultNode && row.node.id === row.defaultNode.id)
            text: "Use"
            primary: true
            onClicked: row.makeDefault()
        }
    }
}
