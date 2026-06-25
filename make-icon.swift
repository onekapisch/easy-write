import AppKit

// Draws a 1024×1024 app icon (gradient squircle + white speech-bubble glyph) to /tmp.
let size: CGFloat = 1024
let image = NSImage(size: NSSize(width: size, height: size))
image.lockFocus()
guard let gctx = NSGraphicsContext.current else { exit(1) }

let margin: CGFloat = size * 0.085
let rect = NSRect(x: margin, y: margin, width: size - 2*margin, height: size - 2*margin)
let radius = (size - 2*margin) * 0.2237
let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)

gctx.saveGraphicsState()
path.addClip()
let grad = NSGradient(starting: NSColor(srgbRed: 0.40, green: 0.31, blue: 0.95, alpha: 1),
                      ending:   NSColor(srgbRed: 0.62, green: 0.28, blue: 0.86, alpha: 1))!
grad.draw(in: rect, angle: -90)
gctx.restoreGraphicsState()

let config = NSImage.SymbolConfiguration(pointSize: size * 0.46, weight: .semibold)
if let base = NSImage(systemSymbolName: "character.bubble.fill", accessibilityDescription: nil),
   let sym = base.withSymbolConfiguration(config) {
    let s = sym.size
    let tinted = NSImage(size: s)
    tinted.lockFocus()
    NSColor.white.set()
    let r = NSRect(origin: .zero, size: s)
    sym.draw(in: r)
    r.fill(using: .sourceAtop)
    tinted.unlockFocus()
    let drawRect = NSRect(x: (size - s.width)/2,
                          y: (size - s.height)/2 - size*0.01,
                          width: s.width, height: s.height)
    tinted.draw(in: drawRect)
}

image.unlockFocus()
guard let tiff = image.tiffRepresentation,
      let rep = NSBitmapImageRep(data: tiff),
      let png = rep.representation(using: .png, properties: [:]) else { exit(2) }
try! png.write(to: URL(fileURLWithPath: "/tmp/ew_icon_1024.png"))
print("wrote /tmp/ew_icon_1024.png")
