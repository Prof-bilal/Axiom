pragma Singleton

// MediaService: the session's media player, over MPRIS (org.mpris.MediaPlayer2).
// Shows the playing player, else the first one; there is no state when no player
// is running. Track text is untrusted: the UI renders it as plain text only.

import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: media

    readonly property var players: Mpris.players ? Mpris.players.values : []

    readonly property var player: {
        var list = players
        for (var i = 0; i < list.length; i++) if (list[i].isPlaying) return list[i]
        return list.length > 0 ? list[0] : null
    }

    readonly property bool available: player !== null
    readonly property string title: player ? (player.trackTitle || "") : ""
    readonly property string artist: player ? (player.trackArtist || "") : ""
    readonly property string artUrl: player ? (player.trackArtUrl || "") : ""
    readonly property bool playing: player ? player.isPlaying : false
    readonly property bool canPlay: player ? player.canTogglePlaying : false
    readonly property bool canNext: player ? player.canGoNext : false
    readonly property bool canPrevious: player ? player.canGoPrevious : false

    function toggle() { if (player && canPlay) player.togglePlaying() }
    function next() { if (player && canNext) player.next() }
    function previous() { if (player && canPrevious) player.previous() }
}
