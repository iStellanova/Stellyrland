import QtQuick
import "../services" as Services

Canvas {
    id: root
    
    property color strokeColor: Services.Colors.border
    property real r: Services.Colors.radiusNormal

    property var popupState: [
        { prop: "nixVisible", w: 330, cr: 12 },
        { prop: "calVisible", w: 330, cr: 12 },
        { prop: "trafficVisible", w: 400, cr: 12 },
        { prop: "ramVisible", w: 330, cr: 12 },
        { prop: "cpuVisible", w: 330, cr: 12 },
        { prop: "gpuVisible", w: 330, cr: 12 },
        { prop: "tempVisible", w: 330, cr: 12 },
        { prop: "mediaVisible", w: 330, cr: 12 },
        { prop: "micVisible", w: 330, cr: 12 },
        { prop: "volumeVisible", w: 330, cr: 12 }
    ]

    property string stateHash: {
        let h = ""
        for (let i = 0; i < popupState.length; i++) {
            h += Services.ShellData[popupState[i].prop] ? "1" : "0"
            if (Services.ShellData[popupState[i].prop]) {
                h += "-" + (Services.ShellData.popupOffsets[popupState[i].prop] || "")
            }
        }
        return h
    }

    onStateHashChanged: root.requestPaint()
    onWidthChanged: root.requestPaint()
    onHeightChanged: root.requestPaint()

    onPaint: {
        let ctx = getContext("2d")
        ctx.reset()
        ctx.strokeStyle = strokeColor
        ctx.lineWidth = 1
        ctx.beginPath()

        let localOffset = root.mapToItem(null, 0, 0).x
        let holes = []
        
        for (let i = 0; i < popupState.length; i++) {
            let p = popupState[i]
            if (Services.ShellData[p.prop]) {
                let xOffset = Services.ShellData.popupOffsets[p.prop]
                if (xOffset !== undefined) {
                    let centerX = xOffset - localOffset
                    let halfW = p.w / 2 + p.cr
                    holes.push({
                        start: centerX - halfW,
                        end: Math.ceil(centerX + halfW)
                    }) // Use Math.ceil to make sure it covers the aliasing edge entirely
                }
            }
        }

        holes.sort((a, b) => a.start - b.start)

        let o = 0.5
        ctx.moveTo(o, r)
        ctx.arc(r, r, r - o, Math.PI, Math.PI * 1.5, false) // Top-Left
        ctx.lineTo(width - r, o)
        ctx.arc(width - r, r, r - o, Math.PI * 1.5, Math.PI * 2, false) // Top-Right
        ctx.lineTo(width - o, height - r)
        ctx.arc(width - r, height - r, r - o, 0, Math.PI * 0.5, false) // Bottom-Right
        
        let currentX = width - r
        let bottomY = height - o
        
        for (let i = holes.length - 1; i >= 0; i--) {
            let h = holes[i]
            if (h.end < currentX && h.end > r) {
                ctx.lineTo(h.end, bottomY)
                ctx.moveTo(Math.max(h.start, r), bottomY)
                currentX = h.start
            } else if (h.end >= currentX && h.start <= currentX) {
                ctx.moveTo(Math.max(h.start, r), bottomY)
                currentX = h.start
            }
        }
        
        if (currentX > r) ctx.lineTo(r, bottomY)
        
        ctx.arc(r, height - r, r - o, Math.PI * 0.5, Math.PI, false) // Bottom-Left
        ctx.lineTo(o, r)
        
        ctx.stroke()
    }
}
