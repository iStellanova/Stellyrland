import QtQuick
import Quickshell
import Quickshell.Hyprland

Item {
    Component.onCompleted: {
        console.log("Clients exists? " + (Hyprland.clients !== undefined));
        if (Hyprland.clients !== undefined) {
            console.log("Length: " + Hyprland.clients.length);
            if (Hyprland.clients.length > 0) {
                let c = Hyprland.clients[0];
                console.log("Props: " + Object.keys(c));
            }
        }
        
        console.log("Monitors exists? " + (Hyprland.monitors !== undefined));
        
        Qt.quit();
    }
}
