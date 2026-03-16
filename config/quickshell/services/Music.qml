pragma Singleton

import Quickshell
import Quickshell.Services.Mpris
import QtQuick

Singleton {
    id: root

    property var players: Mpris.players.values
    
    readonly property var preferredPlayers: ["spotify", "amberol", "lollypop", "vlc", "mpv", "strawberry", "rhythmbox", "cmus", "audacious"]

    function isPreferred(p) {
        if (!p || !p.identity) return false;
        let name = p.identity.toLowerCase();
        for (let i = 0; i < preferredPlayers.length; i++) {
            if (name.includes(preferredPlayers[i])) return true;
        }
        return false;
    }

    property MprisPlayer player: {
        if (!players || players.length === 0) return null;
        
        // 1. Search for a playing PREFERRED player
        for (let i = 0; i < players.length; i++) {
            let p = players[i];
            if (p && p.playbackState === MprisPlaybackState.Playing && isPreferred(p)) return p;
        }

        // 2. Search for a PAUSED PREFERRED player (to keep focus while paused)
        for (let i = 0; i < players.length; i++) {
            let p = players[i];
            if (p && p.playbackState === MprisPlaybackState.Paused && isPreferred(p)) return p;
        }

        // 3. Search for a playing player with artwork
        for (let i = 0; i < players.length; i++) {
            let p = players[i];
            if (p && p.playbackState === MprisPlaybackState.Playing && p.trackArtUrl && p.trackArtUrl !== "") return p;
        }
        
        // 4. Search for any playing player
        for (let i = 0; i < players.length; i++) {
            let p = players[i];
            if (p && p.playbackState === MprisPlaybackState.Playing) return p;
        }

        // 5. Any PREFERRED player (even if stopped)
        for (let i = 0; i < players.length; i++) {
            let p = players[i];
            if (p && isPreferred(p)) return p;
        }
        
        // 6. Any player with artwork
        for (let i = 0; i < players.length; i++) {
            let p = players[i];
            if (p && p.trackArtUrl && p.trackArtUrl !== "") return p;
        }
        
        return players[0];
    }
}
