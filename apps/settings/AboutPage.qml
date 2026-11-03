import QtQuick
import Quickshell
import qs.src.shared
import qs.services
import qs.apps.shared
import "settings.js" as St

PageFrame {
    id: page
    title: "About"

    property string cpu: ""
    property string memory: ""
    property string compositor: ""
    property string shellVersion: ""
    property string terminalVersion: ""

    CommandRunner { id: runner }

    Component.onCompleted: {
        HostService.refresh()
        runner.run(["cat", "/proc/cpuinfo"], function (r) { page.cpu = St.parseCpuModel(r.out) })
        runner.run(["cat", "/proc/meminfo"], function (r) { page.memory = St.formatKb(St.parseMemTotalKb(r.out)) })
        runner.run(["labwc", "--version"], function (r) { page.compositor = r.code === 0 ? St.shortVersion(r.out) : "" })
        runner.run(["quickshell", "--version"], function (r) { page.shellVersion = r.code === 0 ? St.shortVersion(r.out) : "" })
        runner.run(["foot", "--version"], function (r) { page.terminalVersion = r.code === 0 ? St.shortVersion(r.out) : "" })
    }

    Row {
        width: parent.width
        spacing: Theme.spacingLg

        Image {
            width: 72
            height: 72
            source: Quickshell.shellPath("assets/axiom-penguin.png")
            sourceSize.width: 144
            sourceSize.height: 144
            fillMode: Image.PreserveAspectFit
            smooth: true
            mipmap: true
        }
        Column {
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2
            Text {
                text: HostService.osName.length > 0 ? HostService.osName : "Axiom"
                color: Theme.textPrimary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontDisplay
                font.weight: Font.DemiBold
            }
            Text {
                text: "AI-native Linux for developers"
                color: Theme.textSecondary
                font.family: Theme.fontFamily
                font.pixelSize: Theme.fontBody
            }
        }
    }

    SettingsCard {
        title: "Device"
        SettingRow { first: true; label: "Host name"; value: HostService.hostname }
        SettingRow { label: "Processor"; value: page.cpu }
        SettingRow { label: "Memory"; value: page.memory }
        SettingRow { label: "Uptime"; value: HostService.uptime }
    }

    SettingsCard {
        title: "Software"
        SettingRow { first: true; label: "Operating system"; value: HostService.osName }
        SettingRow { label: "Kernel"; value: HostService.kernel; mono: true }
        SettingRow { label: "Desktop"; value: "Axiom Shell"; description: page.shellVersion.length > 0 ? "Runs on " + page.shellVersion : "" }
        SettingRow { label: "Compositor"; value: page.compositor; description: "Temporary harness behind the Axiom session adapter" }
        SettingRow { label: "Terminal"; value: page.terminalVersion }
    }
}
