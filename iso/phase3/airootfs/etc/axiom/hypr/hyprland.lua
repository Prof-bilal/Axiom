-- Axiom session compositor config: Hyprland (ADR-029).
--
-- Hyprland is a replaceable harness behind the Axiom session adapter, not the
-- product contract. It gives the shell rounded windows and simple borders; no blur. Keybinds mirror /etc/axiom/labwc/rc.xml, which stays as the
-- fallback session (axiom-session starts labwc if Hyprland cannot run).

local qs = "qs ipc -p /usr/local/share/axiom/shell call axiom "

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- Started once the compositor is up (labwc equivalent: /etc/axiom/labwc/autostart).
hl.on("hyprland.start", function()
    hl.exec_cmd("/usr/local/bin/axiom-shell >/dev/null 2>&1")
    -- Admin password prompts (pkexec) are answered by the Axiom Shell's own polkit
    -- agent (PolkitDialog.qml); it starts polkit-gnome itself if it cannot register.
end)

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 1,
        col = {
            active_border = "rgba(37f0eab3)",
            inactive_border = "rgba(2a3a40ff)",
        },
        resize_on_border = true,
        layout = "dwindle",
    },
    decoration = {
        rounding = 16, -- Theme.radiusWindow
        shadow = { enabled = true, range = 24, render_power = 3, color = 0x66000000 },
        blur = { enabled = false },
    },
    animations = { enabled = true },
    misc = {
        -- The Axiom Shell draws the wallpaper.
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
    },
    input = {
        -- Empty layout and options: xkbcommon falls back to XKB_DEFAULT_LAYOUT
        -- and XKB_DEFAULT_OPTIONS, which axiom-session exports from Settings.
        kb_layout = "",
        kb_options = "",
        repeat_rate = 25,
        repeat_delay = 600,
        follow_mouse = 2, -- click to focus, as under labwc
    },
})

-- Axiom is a floating desktop: every window floats, as under labwc.
hl.window_rule({ name = "axiom-float", match = { class = ".*" }, float = true })

-- Big third-party windows (browser, editor) open centred and sized to fit under the
-- panel and above the dock, instead of at their own large default size.
hl.window_rule({ name = "axiom-fit", match = { class = "^(firefox|org.mozilla.firefox|chromium|google-chrome|Brave-browser|code|code-oss|Code|VSCodium)$" },
                 size = { "(monitor_w*0.72)", "(monitor_h*0.78)" }, center = true })

-- Four fixed workspaces, as under labwc.
for i = 1, 4 do
    hl.workspace_rule({ workspace = tostring(i), persistent = true })
end

-- applications
hl.bind("SUPER + Return", hl.dsp.exec_cmd("axiom-terminal"))

-- Axiom Shell surfaces (IPC addressed by config path)
hl.bind("SUPER + D", hl.dsp.exec_cmd(qs .. "toggleLauncher"))
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd(qs .. "toggleLauncher"))
hl.bind("SUPER + A", hl.dsp.exec_cmd(qs .. "toggleAxiomMenu"))
hl.bind("SUPER + S", hl.dsp.exec_cmd(qs .. "toggleActivities"))
hl.bind("SUPER + N", hl.dsp.exec_cmd(qs .. "toggleNotificationCenter"))
hl.bind("SUPER + C", hl.dsp.exec_cmd(qs .. "toggleControlCenter"))
hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd(qs .. "toggleSessionMenu"))
hl.bind("SUPER + SHIFT + Return", hl.dsp.exec_cmd("firefox"))

-- media keys: change the level through the shell and show the on-screen display
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(qs .. "volumeStep 5"), { repeating = true, locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(qs .. "volumeStep -5"), { repeating = true, locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(qs .. "volumeMute"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd(qs .. "brightnessStep 10"), { repeating = true, locked = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(qs .. "brightnessStep -10"), { repeating = true, locked = true })
-- Caps Lock: still reaches the application (non_consuming); the shell shows its state
hl.bind("Caps_Lock", hl.dsp.exec_cmd(qs .. "capsLock"), { release = true, non_consuming = true })

-- screenshot and recording bar
hl.bind("Print", hl.dsp.exec_cmd(qs .. "toggleCapture"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd(qs .. "toggleCapture"))

-- windows
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("SUPER + W", hl.dsp.window.close())
hl.bind("ALT + F4", hl.dsp.window.close())
hl.bind("SUPER + M", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind("SUPER + ALT + Up", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind("SUPER + F", hl.dsp.window.fullscreen({ mode = "fullscreen" }))
-- Hyprland has no minimize. SUPER+H parks the window on a hidden workspace;
-- SUPER+SHIFT+H shows that workspace.
hl.bind("SUPER + H", hl.dsp.window.move({ workspace = "special:minimized", follow = false }))
hl.bind("SUPER + SHIFT + H", hl.dsp.workspace.toggle_special("minimized"))
-- Alt+Tab opens the Axiom window switcher (shell overlay); each Tab steps on and
-- releasing Alt picks the highlighted window.
hl.bind("ALT + Tab", hl.dsp.exec_cmd(qs .. "switcherNext"))
hl.bind("ALT + SHIFT + Tab", hl.dsp.exec_cmd(qs .. "switcherPrev"))
hl.bind("ALT + Alt_L", hl.dsp.exec_cmd(qs .. "switcherCommit"), { release = true })
-- Opt-in compositor (ADR-016 amendment): Hyprland draws no title bars, so moving
-- and resizing by mouse needs the SUPER key.
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Snap a floating window to a screen half, below the panel (40 px + gap).
-- shortcut: fixed panel offset and 88% height, wrong once the panel or dock
-- size changes. The shell shows the target zone (SnapHint.qml) as it snaps.
local function snap(right)
    return function()
        local m = hl.get_active_monitor()
        if not m then return end
        hl.exec_cmd(qs .. "snapHint " .. (right and "right" or "left"))
        local w = math.floor(m.width / 2)
        hl.dispatch(hl.dsp.window.resize({ x = w, y = math.floor(m.height * 0.88) }))
        hl.dispatch(hl.dsp.window.move({ x = m.x + (right and w or 0), y = m.y + 44 }))
    end
end
-- Snap to a half: Super+Alt+Left/Right (Super+Left/Right move focus, as in Omarchy).
hl.bind("SUPER + ALT + Left", snap(false))
hl.bind("SUPER + ALT + Right", snap(true))
hl.bind("SUPER + ALT + Down", hl.dsp.window.center())

-- Omarchy-style focus and workspace keys. Focus moves to the nearest window in
-- that direction; Super+Tab cycles the four workspaces.
hl.bind("SUPER + Left", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + Right", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + Up", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + Down", hl.dsp.focus({ direction = "d" }))
hl.bind("SUPER + TAB", hl.dsp.focus({ workspace = "e+1" }))
hl.bind("SUPER + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }))

-- workspaces
for i = 1, 4 do
    hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + " .. i, hl.dsp.window.move({ workspace = i, follow = false }))
end
