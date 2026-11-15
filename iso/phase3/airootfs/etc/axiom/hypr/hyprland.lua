-- Axiom session compositor config: Hyprland (ADR-029).
--
-- Hyprland is a replaceable harness behind the Axiom session adapter, not the
-- product contract. It gives the shell backdrop blur, rounding and gradient
-- borders. Keybinds mirror /etc/axiom/labwc/rc.xml, which stays as the
-- fallback session (axiom-session starts labwc if Hyprland cannot run).

local qs = "qs ipc -p /usr/local/share/axiom/shell call axiom "

hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })

-- Started once the compositor is up (labwc equivalent: /etc/axiom/labwc/autostart).
hl.on("hyprland.start", function()
    hl.exec_cmd("/usr/local/bin/axiom-shell >/dev/null 2>&1")
    -- Admin password prompts (pkexec) need an authentication agent in the session.
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 >/dev/null 2>&1")
end)

hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 1,
        col = {
            -- Glass edge: Theme.glassEdgeStart -> glassEdgeEnd (colors.toml [glass]).
            active_border = { colors = { "rgba(37f0eab3)", "rgba(ffb348b3)" }, angle = 45 },
            inactive_border = "rgba(23323899)",
        },
        resize_on_border = true,
        layout = "dwindle",
    },
    decoration = {
        rounding = 16, -- Theme.radiusWindow
        shadow = { enabled = true, range = 24, render_power = 3, color = 0x66000000 },
        blur = { enabled = true, size = 8, passes = 3, vibrancy = 0.17 },
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

-- Four fixed workspaces, as under labwc.
for i = 1, 4 do
    hl.workspace_rule({ workspace = tostring(i), persistent = true })
end

-- Blur behind the shell's glass surfaces. ignore_alpha 0.1 skips fully clear
-- pixels; the glass fills (alpha 0.16 / 0.24) are blurred. The launcher draws
-- no full-screen scrim, so only its card and the bars are blurred.
-- axiom-wallpaper is left out on purpose.
for _, ns in ipairs({
    "axiom-panel", "axiom-dock", "axiom-menu", "axiom-launcher", "axiom-activities",
    "axiom-control-center", "axiom-notification-center", "axiom-notifications-toast",
    "axiom-session-menu", "axiom-switcher",
}) do
    hl.layer_rule({ name = "glass-" .. ns, match = { namespace = "^" .. ns .. "$" },
                    blur = true, ignore_alpha = 0.1 })
end

-- applications
hl.bind("SUPER + Return", hl.dsp.exec_cmd("axiom-terminal"))

-- Axiom Shell surfaces (IPC addressed by config path)
hl.bind("SUPER + D", hl.dsp.exec_cmd(qs .. "toggleLauncher"))
hl.bind("SUPER + A", hl.dsp.exec_cmd(qs .. "toggleAxiomMenu"))
hl.bind("SUPER + S", hl.dsp.exec_cmd(qs .. "toggleActivities"))
hl.bind("SUPER + N", hl.dsp.exec_cmd(qs .. "toggleNotificationCenter"))
hl.bind("SUPER + C", hl.dsp.exec_cmd(qs .. "toggleControlCenter"))
hl.bind("SUPER + SHIFT + E", hl.dsp.exec_cmd(qs .. "toggleSessionMenu"))

-- windows
hl.bind("SUPER + Q", hl.dsp.window.close())
hl.bind("ALT + F4", hl.dsp.window.close())
hl.bind("SUPER + M", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind("SUPER + Up", hl.dsp.window.fullscreen({ mode = "maximized" }))
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
-- Windows have no title bar under Hyprland until Axiom apps draw their own
-- (ADR-029), so moving and resizing by mouse needs the SUPER key.
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Snap a floating window to a screen half, below the panel (40 px + gap).
-- shortcut: fixed panel offset and 88% height, wrong once the panel or dock
-- size changes; replace with the shell's snap overlay (plan M3).
local function snap(right)
    return function()
        local m = hl.get_active_monitor()
        if not m then return end
        local w = math.floor(m.width / 2)
        hl.dispatch(hl.dsp.window.resize({ x = w, y = math.floor(m.height * 0.88) }))
        hl.dispatch(hl.dsp.window.move({ x = m.x + (right and w or 0), y = m.y + 44 }))
    end
end
hl.bind("SUPER + Left", snap(false))
hl.bind("SUPER + Right", snap(true))
hl.bind("SUPER + Down", hl.dsp.window.center())

-- workspaces
for i = 1, 4 do
    hl.bind("SUPER + " .. i, hl.dsp.focus({ workspace = i }))
    hl.bind("SUPER + SHIFT + " .. i, hl.dsp.window.move({ workspace = i, follow = false }))
end
