import AppKit

// Read-only pixel comparison of the real MenuPanelView snapshots. Padding belongs to
// the test backdrop; every pixel inside the panel must be independent of that backdrop.
let root = URL(fileURLWithPath: CommandLine.arguments[1])
var failures = 0
for mode in ["light", "dark"] {
    let white = NSBitmapImageRep(data: try Data(contentsOf: root.appendingPathComponent("a-panel-\(mode)-white.png")))!
    let black = NSBitmapImageRep(data: try Data(contentsOf: root.appendingPathComponent("a-panel-\(mode)-black.png")))!
    precondition(white.pixelsWide == black.pixelsWide && white.pixelsHigh == black.pixelsHigh)
    var different = 0
    var transparent = 0
    for y in 48..<(white.pixelsHigh - 48) {
        for x in 48..<(white.pixelsWide - 48) {
            let a = white.colorAt(x: x, y: y)!.usingColorSpace(.sRGB)!
            let b = black.colorAt(x: x, y: y)!.usingColorSpace(.sRGB)!
            if a.alphaComponent < 0.999 || b.alphaComponent < 0.999 { transparent += 1 }
            if max(abs(a.redComponent - b.redComponent), abs(a.greenComponent - b.greenComponent),
                   abs(a.blueComponent - b.blueComponent)) > 1.1 / 255 { different += 1 }
        }
    }
    print("\(mode): \(different) backdrop-dependent pixels, \(transparent) transparent pixels")
    if different != 0 || transparent != 0 { failures += 1 }
}
exit(failures == 0 ? 0 : 1)
