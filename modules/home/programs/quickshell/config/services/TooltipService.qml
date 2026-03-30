pragma Singleton
import QtQuick
import Quickshell

/**
 * TooltipService.qml
 * Neutered - Tooltips removed at user request.
 */
Singleton {
    id: root
    function show(target, text, xPos, yPos) { /* No-op */ }
    function hide(target) { /* No-op */ }
}
