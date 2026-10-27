import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Io
import Quickshell.Services.Notifications
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Networking

ShellRoot {
  id: root

  readonly property var primaryScreen: Quickshell.screens.length > 0 ? Quickshell.screens[0] : null
  readonly property string home: Quickshell.env("HOME") || "/home/omarchy"
  readonly property string penguinAsset: {
    var explicit = Quickshell.env("AXIOM_PENGUIN")
    if (explicit) return explicit.indexOf("file:") === 0 ? explicit : "file://" + explicit
    return "file://" + home + "/.local/share/axiom/axiom-penguin.png"
  }
  readonly property string wallpaperSource: {
    var explicit = Quickshell.env("AXIOM_WALLPAPER")
    if (explicit) return explicit.indexOf("file:") === 0 ? explicit : "file://" + explicit
    return "file://" + home + "/.local/share/axiom/aurora.png"
  }

  readonly property color background: "#0b1116"
  readonly property color surface: "#141e24"
  readonly property color surfaceHigh: "#1b2930"
  readonly property color foreground: "#ecf2f4"
  readonly property color muted: "#7d9199"
  readonly property color accent: "#64d8c5"
  readonly property color accentDeep: "#2fa99a"
  readonly property color border: "#2a3a42"
  readonly property color danger: "#ff8b8b"
  readonly property color warning: "#f3d27a"

  property bool launcherOpen: false
  property bool controlOpen: false
  property bool notificationsVisible: false
  property string clockText: ""
  property string statsText: "waiting for sample…"
  property string launcherQuery: ""
  property var launcherResults: []
  property int launcherIndex: 0
  property var toasts: []

  function pad(value) { return value < 10 ? "0" + value : String(value) }
  function updateClock() {
    var d = new Date()
    var days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    var months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
    clockText = days[d.getDay()] + ", " + months[d.getMonth()] + " " + d.getDate() +
      "  " + pad(d.getHours()) + ":" + pad(d.getMinutes())
  }

  function workspaceFocused(id) {
    return Hyprland.focusedWorkspace !== null && Hyprland.focusedWorkspace.id === id
  }

  function workspaceOccupied(id) {
    var values = Hyprland.workspaces.values || []
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i].toplevels.values.length > 0
    }
    return false
  }

  function focusWorkspace(id) {
    Quickshell.execDetached(["hyprctl", "dispatch", "hl.dsp.focus({ workspace = \"" + id + "\" })"])
  }

  function closePanels() {
    launcherOpen = false
    controlOpen = false
  }

  function openLauncher() {
    launcherQuery = ""
    updateLauncherResults()
    launcherOpen = true
    controlOpen = false
  }

  function openControl() {
    launcherOpen = false
    controlOpen = true
  }

  function toggleLauncher() {
    if (launcherOpen) closePanels()
    else openLauncher()
  }

  function updateLauncherResults() {
    var query = String(launcherQuery || "").toLowerCase()
    var values = DesktopEntries.applications.values || []
    var results = []
    for (var i = 0; i < values.length; i++) {
      var entry = values[i]
      if (!entry || entry.noDisplay) continue
      var name = String(entry.name || "")
      if (query.length > 0 && name.toLowerCase().indexOf(query) === -1) continue
      results.push(entry)
    }
    results.sort(function(a, b) { return String(a.name).localeCompare(String(b.name)) })
    launcherResults = results.slice(0, 10)
    launcherIndex = 0
  }

  function launchEntry(entry) {
    if (!entry) return
    var id = String(entry.id || "")
    if (id.length === 0) return
    if (id.slice(-8) !== ".desktop") id += ".desktop"
    Quickshell.execDetached(["gtk-launch", id])
    closePanels()
  }

  function runCommand(args) {
    Quickshell.execDetached(args)
    closePanels()
  }

  function dismissToast(toast) {
    if (toast && toast.ref) {
      try { toast.ref.dismiss() } catch (e) {}
    }
    var remaining = []
    for (var i = 0; i < toasts.length; i++) {
      if (toasts[i].id !== toast.id) remaining.push(toasts[i])
    }
    toasts = remaining
  }

  function addNotification(notification) {
    notification.tracked = true
    var item = {
      id: String(Date.now()) + "-" + String(Math.random()),
      app: String(notification.appName || "System"),
      title: String(notification.summary || "Notification"),
      body: String(notification.body || ""),
      ref: notification
    }
    toasts = [item].concat(toasts).slice(0, 3)
  }

  function toggleAudioMute() {
    var sink = Pipewire.defaultAudioSink
    if (sink && sink.audio) sink.audio.muted = !sink.audio.muted
  }

  function audioLabel() {
    var sink = Pipewire.defaultAudioSink
    if (!sink || !sink.audio) return "MUTE"
    if (sink.audio.muted) return "MUTE"
    return Math.round(sink.audio.volume * 100) + "%"
  }

  function batteryLabel() {
    var device = UPower.displayDevice
    if (!device || !UPower.onBattery || device.percentage < 0) return "AC"
    return Math.round(device.percentage) + "%"
  }

  function networkLabel() {
    var devices = Networking.devices.values || []
    for (var i = 0; i < devices.length; i++) {
      if (devices[i] && devices[i].connected) return "NET"
    }
    return "OFF"
  }

  function networkIcon() {
    return networkLabel() === "NET" ? "network-wireless-signal-excellent-symbolic"
                                    : "network-wireless-offline-symbolic"
  }

  function audioIcon() {
    var sink = Pipewire.defaultAudioSink
    if (!sink || !sink.audio || sink.audio.muted) return "audio-volume-muted-symbolic"
    return "audio-volume-high-symbolic"
  }

  function batteryIcon() {
    var device = UPower.displayDevice
    if (!device || !UPower.onBattery || device.percentage < 0) return "ac-adapter-symbolic"
    if (device.percentage >= 70) return "battery-full-symbolic"
    if (device.percentage >= 35) return "battery-good-symbolic"
    if (device.percentage >= 15) return "battery-low-symbolic"
    return "battery-caution-symbolic"
  }

  NotificationServer {
    id: notificationServer
    keepOnReload: false
    imageSupported: true
    actionsSupported: true
    bodyMarkupSupported: true
    bodyHyperlinksSupported: true
    persistenceSupported: true

    onNotification: function(notification) {
      root.addNotification(notification)
    }
  }

  Component.onCompleted: {
    updateClock()
    updateLauncherResults()
  }

  Timer {
    interval: 1000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.updateClock()
  }

  Timer {
    interval: 2000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: if (!stats.running) stats.running = true
  }

  Process {
    id: stats
    command: ["sh", "-c", "printf 'load  '; cut -d' ' -f1-3 /proc/loadavg; printf '\\nmem   '; awk '/MemTotal|MemAvailable/ {printf \"%s=%s \" , $1, $2}' /proc/meminfo; printf '\\npsi   '; tr '\\n' ' ' < /proc/pressure/memory 2>/dev/null; printf '\\nprocs '; ps -e --no-headers 2>/dev/null | wc -l"]
    stdout: StdioCollector {
      onStreamFinished: root.statsText = text
    }
  }

  IpcHandler {
    target: "axiom.shell"
    function ping(): string { return "ok" }
    function openLauncher(): void { root.openLauncher() }
    function openControl(): void { root.openControl() }
    function closePanels(): void { root.closePanels() }
    function toggleLauncher(): void { root.toggleLauncher() }
    function workspace(id: string): void { root.focusWorkspace(Number(id)) }
    function launchTerminal(): void { root.runCommand(["foot"]) }
    function state(): string { return root.launcherOpen ? "launcher" : root.controlOpen ? "control" : "closed" }
  }

  component BarChip: Rectangle {
    id: chip
    property string label: ""
    property bool active: false
    signal clicked()

    height: 22
    width: Math.max(24, labelText.implicitWidth + 14)
    radius: 6
    color: active ? root.accent : (pointer.containsMouse ? root.surfaceHigh : "transparent")
    border.width: 1
    border.color: active ? root.accent : (pointer.containsMouse ? root.border : "transparent")

    Text {
      id: labelText
      anchors.centerIn: parent
      text: chip.label
      color: chip.active ? root.background : root.foreground
      font.pixelSize: 11
      font.weight: chip.active ? Font.DemiBold : Font.Normal
    }

    MouseArea {
      id: pointer
      anchors.fill: parent
      hoverEnabled: true
      onClicked: chip.clicked()
    }

    Accessible.role: Accessible.Button
    Accessible.name: chip.label
  }

  component PenguinMark: Item {
    id: mark
    property int markSize: 22

    implicitWidth: markSize
    implicitHeight: markSize

    Image {
      id: penguinImage
      anchors.fill: parent
      source: root.penguinAsset
      sourceSize.width: mark.markSize * 2
      sourceSize.height: mark.markSize * 2
      fillMode: Image.PreserveAspectFit
      visible: status === Image.Ready
    }

    Text {
      anchors.centerIn: parent
      text: "🐧"
      font.pixelSize: Math.round(mark.markSize * 0.8)
      visible: !penguinImage.visible
    }
  }

  component StatusIcon: Item {
    id: status
    property string iconName: ""
    property string label: ""
    signal clicked()

    implicitWidth: 22
    implicitHeight: 20

    Image {
      anchors.centerIn: parent
      width: 16
      height: 16
      source: status.iconName ? Quickshell.iconPath(status.iconName, true) : ""
      sourceSize.width: 16
      sourceSize.height: 16
      fillMode: Image.PreserveAspectFit
      opacity: pointer.containsMouse ? 1 : 0.85
    }

    MouseArea {
      id: pointer
      anchors.fill: parent
      hoverEnabled: true
      onClicked: status.clicked()
    }

    Accessible.role: Accessible.Button
    Accessible.name: status.label
  }

  component DockButton: Rectangle {
    id: button
    property string iconName: ""
    property string imageSource: ""
    property string glyph: ""
    property string label: ""
    property bool active: false
    signal clicked()

    width: 42
    height: 42
    radius: 11
    color: active ? root.accentDeep : (pointer.containsMouse ? root.surfaceHigh : root.surface)
    border.width: 1
    border.color: pointer.containsMouse ? root.accent : root.border

    Image {
      id: buttonIcon
      anchors.centerIn: parent
      width: 22
      height: 22
      source: button.imageSource.length > 0 ? button.imageSource
              : (button.iconName.length > 0 ? Quickshell.iconPath(button.iconName, true) : "")
      sourceSize.width: 22
      sourceSize.height: 22
      fillMode: Image.PreserveAspectFit
      visible: status === Image.Ready && (button.imageSource.length > 0 || button.iconName.length > 0)
    }

    Text {
      anchors.centerIn: parent
      text: button.glyph
      color: button.active ? root.background : root.foreground
      font.pixelSize: 16
      font.weight: Font.DemiBold
      visible: button.glyph.length > 0 && (!buttonIcon.visible)
    }

    MouseArea {
      id: pointer
      anchors.fill: parent
      hoverEnabled: true
      onClicked: button.clicked()
    }

    Accessible.role: Accessible.Button
    Accessible.name: button.label
  }

  component WelcomeTile: Rectangle {
    id: tile
    property string iconName: ""
    property string glyph: ""
    property string label: ""
    property bool active: false
    signal clicked()

    width: 82
    height: 58
    radius: 10
    color: tile.active ? root.accentDeep : (tilePointer.containsMouse ? root.surfaceHigh : "transparent")
    border.width: 1
    border.color: tile.active ? root.accent : "transparent"

    Column {
      anchors.centerIn: parent
      spacing: 2
      Image {
        id: tileIcon
        anchors.horizontalCenter: parent.horizontalCenter
        width: 20
        height: 20
        source: tile.iconName ? Quickshell.iconPath(tile.iconName, true) : ""
        sourceSize.width: 20
        sourceSize.height: 20
        visible: tile.iconName.length > 0 && status === Image.Ready
      }
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: tile.glyph
        color: tile.active ? root.background : root.foreground
        font.pixelSize: 16
        visible: tile.glyph.length > 0 && !tileIcon.visible
      }
      Text {
        anchors.horizontalCenter: parent.horizontalCenter
        text: tile.label
        color: tile.active ? root.background : root.muted
        font.pixelSize: 9
      }
    }

    MouseArea {
      id: tilePointer
      anchors.fill: parent
      hoverEnabled: true
      onClicked: tile.clicked()
    }

    Accessible.role: Accessible.Button
    Accessible.name: tile.label
  }

  // Background is a Quickshell layer-shell surface, so the wallpaper belongs to
  // Axiom Shell rather than the compositor or an Omarchy background service.
  PanelWindow {
    id: backgroundWindow
    screen: root.primaryScreen
    anchors {
      top: true
      bottom: true
      left: true
      right: true
    }
    color: root.background
    surfaceFormat.opaque: true
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "axiom-background"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore

    Image {
      anchors.fill: parent
      source: root.wallpaperSource
      fillMode: Image.PreserveAspectCrop
      asynchronous: true
    }
  }

  PanelWindow {
    id: welcomeWindow
    screen: root.primaryScreen
    anchors {
      top: true
      bottom: true
      left: true
      right: true
    }
    color: "transparent"
    surfaceFormat.opaque: false
    WlrLayershell.layer: WlrLayer.Bottom
    WlrLayershell.namespace: "axiom-welcome"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    mask: Region { item: welcomeCard }

    Rectangle {
      id: welcomeCard
      width: Math.min(640, parent.width - 80)
      height: 252
      anchors.centerIn: parent
      radius: 20
      color: "#D9141e24"
      border.width: 1
      border.color: root.border

      Row {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 20

        Rectangle {
          width: 158
          height: 216
          radius: 16
          color: "#E60b1116"
          border.width: 1
          border.color: root.border

          PenguinMark {
            anchors.centerIn: parent
            markSize: 132
          }
        }

        Column {
          width: parent.width - 198
          anchors.verticalCenter: parent.verticalCenter
          spacing: 8

          Text {
            text: "A X I O M"
            color: root.muted
            font.pixelSize: 11
            font.weight: Font.DemiBold
            font.letterSpacing: 3
          }

          Row {
            spacing: 5
            Text {
              text: "Welcome"
              color: root.foreground
              font.pixelSize: 30
              font.weight: Font.DemiBold
            }
            Text {
              text: "back"
              color: root.accent
              font.pixelSize: 30
              font.weight: Font.DemiBold
            }
          }

          Text {
            text: "A calm developer operating system\nfor focused work."
            color: root.muted
            font.pixelSize: 12
            lineHeight: 1.25
          }

          Item { height: 4; width: 1 }

          Row {
            spacing: 8

            WelcomeTile {
              label: "Open launcher"
              glyph: "▦"
              active: true
              onClicked: root.openLauncher()
            }
            WelcomeTile {
              label: "Terminal"
              iconName: "utilities-terminal"
              onClicked: root.runCommand(["foot"])
            }
            WelcomeTile {
              label: "Files"
              iconName: "system-file-manager"
              onClicked: root.runCommand(["nautilus"])
            }
            WelcomeTile {
              label: "Settings"
              iconName: "preferences-system"
              onClicked: root.openControl()
            }
          }
        }
      }
    }
  }

  PanelWindow {
    id: barWindow
    screen: root.primaryScreen
    anchors {
      top: true
      left: true
      right: true
    }
    implicitHeight: 34
    color: "transparent"
    surfaceFormat.opaque: false
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "axiom-bar"
    exclusionMode: ExclusionMode.Auto

    Rectangle {
      anchors.fill: parent
      color: "#E60b1116"
      Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: 1
        color: root.border
      }
    }

    RowLayout {
      anchors.fill: parent
      anchors.leftMargin: 8
      anchors.rightMargin: 24
      spacing: 7

      PenguinMark {
        markSize: 22
        Accessible.name: "Axiom penguin"
      }
      Text {
        text: "AXIOM"
        color: root.foreground
        font.pixelSize: 12
        font.weight: Font.DemiBold
        font.letterSpacing: 3
        Accessible.name: "Axiom desktop"
      }

      Item { width: 3 }

      Repeater {
        model: 5
        BarChip {
          required property int index
          label: String(index + 1)
          active: root.workspaceFocused(index + 1)
          opacity: active || root.workspaceOccupied(index + 1) ? 1 : 0.55
          onClicked: root.focusWorkspace(index + 1)
        }
      }

      BarChip {
        label: "▦"
        active: root.launcherOpen
        onClicked: root.toggleLauncher()
      }

      Item { Layout.fillWidth: true }

      StatusIcon {
        iconName: root.networkIcon()
        label: "Network " + root.networkLabel()
      }

      StatusIcon {
        iconName: root.audioIcon()
        label: "Volume " + root.audioLabel()
        onClicked: root.toggleAudioMute()
      }

      RowLayout {
        spacing: 4
        StatusIcon {
          iconName: root.batteryIcon()
          label: "Power " + root.batteryLabel()
        }
        Text {
          text: root.batteryLabel()
          color: root.muted
          font.pixelSize: 10
        }
      }

      Text {
        text: root.clockText
        color: root.foreground
        font.pixelSize: 11
        Layout.preferredWidth: 132
        horizontalAlignment: Text.AlignRight
        Accessible.name: root.clockText
      }
    }
  }

  PanelWindow {
    id: dockWindow
    screen: root.primaryScreen
    anchors {
      bottom: true
      left: true
      right: true
    }
    implicitHeight: 86
    color: "transparent"
    surfaceFormat.opaque: false
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "axiom-dock"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    mask: Region { item: dockCard }

    Rectangle {
      id: dockCard
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 14
      width: 350
      height: 58
      radius: 18
      color: "#E6141e24"
      border.width: 1
      border.color: root.border

      Row {
        anchors.centerIn: parent
        spacing: 8

        DockButton {
          imageSource: root.penguinAsset
          glyph: "▦"
          label: "Axiom launcher"
          active: root.launcherOpen
          onClicked: root.toggleLauncher()
        }
        DockButton {
          iconName: "utilities-terminal"
          glyph: ">_"
          label: "Terminal"
          onClicked: root.runCommand(["foot"])
        }
        DockButton {
          iconName: "system-file-manager"
          glyph: "▤"
          label: "Files"
          onClicked: root.runCommand(["nautilus"])
        }
        DockButton {
          iconName: "preferences-system"
          glyph: "⚙"
          label: "Control Center"
          active: root.controlOpen
          onClicked: root.openControl()
        }
        DockButton {
          iconName: "web-browser"
          glyph: "◉"
          label: "Browser"
          onClicked: root.runCommand(["xdg-open", "https://axiom.local"])
        }
        DockButton {
          iconName: "weather-clear-night-symbolic"
          glyph: "☾"
          label: "Appearance"
          onClicked: root.openControl()
        }
      }
    }
  }

  PanelWindow {
    id: overlayWindow
    screen: root.primaryScreen
    anchors {
      top: true
      bottom: true
      left: true
      right: true
    }
    visible: root.launcherOpen || root.controlOpen
    color: "transparent"
    surfaceFormat.opaque: false
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "axiom-overlay"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore

    Rectangle {
      anchors.fill: parent
      color: "#A6000000"
      MouseArea {
        anchors.fill: parent
        onClicked: root.closePanels()
      }
    }

    Rectangle {
      id: launcherCard
      visible: root.launcherOpen
      width: Math.min(560, parent.width - 48)
      height: Math.min(430, parent.height - 96)
      anchors.centerIn: parent
      radius: 16
      color: "#F20b1116"
      border.width: 1
      border.color: root.accent
      MouseArea { anchors.fill: parent }

      Column {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        Row {
          width: parent.width
          spacing: 10
          Text {
            text: "◈"
            color: root.accent
            font.pixelSize: 22
            font.weight: Font.Bold
          }
          Text {
            text: "Axiom Launcher"
            color: root.foreground
            font.pixelSize: 16
            font.weight: Font.DemiBold
          }
          Item { width: parent.width - 300; height: 1 }
          Text {
            text: "Esc  close"
            color: root.muted
            font.pixelSize: 10
          }
        }

        Rectangle {
          width: parent.width
          height: 44
          radius: 10
          color: root.surface
          border.width: 1
          border.color: search.activeFocus ? root.accent : root.border

          TextInput {
            id: search
            anchors.fill: parent
            anchors.leftMargin: 14
            anchors.rightMargin: 14
            verticalAlignment: TextInput.AlignVCenter
            text: root.launcherQuery
            color: root.foreground
            selectionColor: root.accentDeep
            font.pixelSize: 15
            focus: root.launcherOpen
            onTextChanged: {
              root.launcherQuery = text
              root.updateLauncherResults()
            }
            onAccepted: root.launchEntry(root.launcherResults[root.launcherIndex])
            Keys.onEscapePressed: root.closePanels()
            Keys.onUpPressed: {
              root.launcherIndex = Math.max(0, root.launcherIndex - 1)
              event.accepted = true
            }
            Keys.onDownPressed: {
              root.launcherIndex = Math.min(root.launcherResults.length - 1, root.launcherIndex + 1)
              event.accepted = true
            }
            Accessible.name: "Search applications"
          }

          Text {
            anchors.left: parent.left
            anchors.leftMargin: 14
            anchors.verticalCenter: parent.verticalCenter
            text: "Search applications…"
            color: root.muted
            font.pixelSize: 14
            visible: search.text.length === 0
          }
        }

        ListView {
          width: parent.width
          height: parent.height - 92
          clip: true
          spacing: 2
          model: root.launcherResults
          currentIndex: root.launcherIndex
          boundsBehavior: Flickable.StopAtBounds

          delegate: Rectangle {
            required property var modelData
            required property int index
            width: ListView.view.width
            height: 44
            radius: 8
            color: index === root.launcherIndex ? root.surfaceHigh : "transparent"
            border.width: index === root.launcherIndex ? 1 : 0
            border.color: root.accent

            Row {
              anchors.fill: parent
              anchors.leftMargin: 8
              anchors.rightMargin: 8
              spacing: 10

              Image {
                width: 24
                height: 24
                anchors.verticalCenter: parent.verticalCenter
                source: Quickshell.iconPath(modelData.icon, true)
                sourceSize.width: 24
                sourceSize.height: 24
              }
              Column {
                anchors.verticalCenter: parent.verticalCenter
                width: parent.width - 50
                Text {
                  text: String(modelData.name || "")
                  color: root.foreground
                  font.pixelSize: 12
                  font.weight: Font.DemiBold
                  elide: Text.ElideRight
                  width: parent.width
                }
                Text {
                  text: String(modelData.genericName || modelData.comment || "")
                  color: root.muted
                  font.pixelSize: 10
                  elide: Text.ElideRight
                  width: parent.width
                }
              }
            }

            MouseArea {
              anchors.fill: parent
              hoverEnabled: true
              onEntered: root.launcherIndex = index
              onClicked: root.launchEntry(modelData)
            }

            Accessible.role: Accessible.ListItem
            Accessible.name: String(modelData.name || "")
          }

          Text {
            anchors.centerIn: parent
            visible: root.launcherResults.length === 0
            text: "No applications found"
            color: root.muted
            font.pixelSize: 12
          }
        }
      }
    }

    Rectangle {
      id: controlCard
      visible: root.controlOpen
      width: Math.min(520, parent.width - 48)
      height: Math.min(360, parent.height - 120)
      anchors.centerIn: parent
      radius: 16
      color: "#F20b1116"
      border.width: 1
      border.color: root.accent
      MouseArea { anchors.fill: parent }

      Column {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 14

        Row {
          width: parent.width
          Text {
            text: "Axiom Control Center"
            color: root.foreground
            font.pixelSize: 16
            font.weight: Font.DemiBold
          }
          Item { width: parent.width - 300; height: 1 }
          Text {
            text: "Esc  close"
            color: root.muted
            font.pixelSize: 10
          }
        }

        Text {
          text: "System snapshot"
          color: root.accent
          font.pixelSize: 11
          font.weight: Font.DemiBold
        }
        Text {
          width: parent.width
          text: root.statsText
          color: root.foreground
          font.family: "monospace"
          font.pixelSize: 10
          lineHeight: 1.35
          wrapMode: Text.WrapAnywhere
        }

        Rectangle { width: parent.width; height: 1; color: root.border }

        Text { text: "Agent runtime   not connected (Phase 5)"; color: root.muted; font.pixelSize: 11 }
        Text { text: "Shield          not active (Phase 7)"; color: root.muted; font.pixelSize: 11 }
        Text { text: "Flow            not measuring (Phase 9)"; color: root.muted; font.pixelSize: 11 }

        Row {
          spacing: 8
          BarChip { label: "Open launcher"; onClicked: root.openLauncher() }
          BarChip { label: "Close"; onClicked: root.closePanels() }
        }
      }
    }
  }

  PanelWindow {
    id: notificationWindow
    screen: root.primaryScreen
    anchors {
      top: true
      right: true
    }
    margins.top: 44
    margins.right: 12
    implicitWidth: 360
    implicitHeight: Math.max(0, root.toasts.length * 88 + 8)
    visible: root.toasts.length > 0
    color: "transparent"
    surfaceFormat.opaque: false
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "axiom-notifications"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore
    mask: Region { item: toastColumn }

    Column {
      id: toastColumn
      width: parent.width
      spacing: 8

      Repeater {
        model: root.toasts
        Rectangle {
          required property var modelData
          width: toastColumn.width
          height: 80
          radius: 10
          color: "#F21b2930"
          border.width: 1
          border.color: root.accent

          Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 3
            Text {
              width: parent.width
              text: String(modelData.app || "")
              color: root.accent
              font.pixelSize: 10
              font.weight: Font.DemiBold
            }
            Text {
              width: parent.width
              text: String(modelData.title || "")
              color: root.foreground
              font.pixelSize: 12
              font.weight: Font.DemiBold
              elide: Text.ElideRight
            }
            Text {
              width: parent.width
              text: String(modelData.body || "")
              color: root.muted
              font.pixelSize: 10
              elide: Text.ElideRight
            }
          }

          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: root.dismissToast(modelData)
          }

          Timer {
            interval: 9000
            running: true
            onTriggered: root.dismissToast(modelData)
          }
        }
      }
    }
  }
}
