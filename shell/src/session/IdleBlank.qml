import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

// Turns the screens off after the idle time chosen in Settings > Power, and
// back on at the first key or pointer event. Uses the compositor's idle
// protocol and output power control, so there is no extra daemon.
Scope {
    // IdleMonitor reads its timeout when it is created, so a new monitor is
    // created whenever the chosen idle time changes (an empty model means off).
    // Instantiator, not Repeater: a Repeater under a non-visual Scope never creates its delegate.
    Instantiator {
        model: SettingsService.idleBlankMinutes > 0 ? [SettingsService.idleBlankMinutes] : []
        delegate: IdleMonitor {
            required property int modelData
            timeout: modelData * 60
            respectInhibitors: true
            onIsIdleChanged: DisplayService.setAllPower(!isIdle)
        }
    }
}
