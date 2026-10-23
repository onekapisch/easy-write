// Renders the DMG window background (660×400 pt, 1x + 2x) into dmg/background.tiff.
// Run from the repo root:  swift dmg/make-background.swift
import AppKit

let size = NSSize(width: 660, height: 400)

func render(scale: CGFloat) -> NSBitmapImageRep {
    let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(size.width * scale), pixelsHigh: Int(size.height * scale),
                               bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                               colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
    rep.size = size
    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    let ctx = NSGraphicsContext.current!.cgContext

    // Charcoal with a purple glow, like the panel and the promo end card.
    NSColor(srgbRed: 0.075, green: 0.07, blue: 0.10, alpha: 1).setFill()
    NSRect(origin: .zero, size: size).fill()
    let glow = NSGradient(colors: [NSColor(srgbRed: 0.49, green: 0.36, blue: 1, alpha: 0.45), .clear])!
    glow.draw(fromCenter: NSPoint(x: 110, y: 380), radius: 0, toCenter: NSPoint(x: 110, y: 380), radius: 360, options: [])
    let glow2 = NSGradient(colors: [NSColor(srgbRed: 1, green: 0.58, blue: 0.8, alpha: 0.18), .clear])!
    glow2.draw(fromCenter: NSPoint(x: 600, y: 20), radius: 0, toCenter: NSPoint(x: 600, y: 20), radius: 300, options: [])

    // Arrow from the app icon (x≈180) to Applications (x≈480), icons centred at y≈210 (from top).
    let y = size.height - 205
    ctx.setStrokeColor(NSColor(white: 1, alpha: 0.55).cgColor)
    ctx.setLineWidth(3)
    ctx.setLineCap(.round)
    ctx.setLineDash(phase: 0, lengths: [2, 9])
    ctx.move(to: CGPoint(x: 262, y: y)); ctx.addLine(to: CGPoint(x: 388, y: y)); ctx.strokePath()
    ctx.setLineDash(phase: 0, lengths: [])
    ctx.move(to: CGPoint(x: 378, y: y + 10)); ctx.addLine(to: CGPoint(x: 392, y: y)); ctx.addLine(to: CGPoint(x: 378, y: y - 10))
    ctx.strokePath()

    func text(_ s: String, _ font: NSFont, _ color: NSColor, y: CGFloat) {
        let p = NSMutableParagraphStyle(); p.alignment = .center
        let a: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color, .paragraphStyle: p]
        (s as NSString).draw(in: NSRect(x: 0, y: y, width: size.width, height: 30), withAttributes: a)
    }
    text("Drag Easy Write into Applications", .systemFont(ofSize: 17, weight: .semibold), NSColor(white: 1, alpha: 0.92), y: 72)
    text("Free · Open source · Runs entirely on your Mac", .systemFont(ofSize: 12.5), NSColor(white: 1, alpha: 0.5), y: 46)

    NSGraphicsContext.restoreGraphicsState()
    return rep
}

let dir = URL(fileURLWithPath: CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "dmg")
let tmp = FileManager.default.temporaryDirectory
for (scale, name) in [(1.0, "bg.png"), (2.0, "bg@2x.png")] {
    try! render(scale: scale).representation(using: .png, properties: [:])!.write(to: tmp.appendingPathComponent(name))
}
let p = Process()
p.executableURL = URL(fileURLWithPath: "/usr/bin/tiffutil")
p.arguments = ["-cathidpicheck", tmp.appendingPathComponent("bg.png").path, tmp.appendingPathComponent("bg@2x.png").path,
               "-out", dir.appendingPathComponent("background.tiff").path]
try! p.run(); p.waitUntilExit()
print("Wrote \(dir.appendingPathComponent("background.tiff").path)")
