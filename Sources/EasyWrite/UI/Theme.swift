import SwiftUI
import AppKit

/// Easy Write's visual language, matching the OneKapisch menu-bar apps: layered panels,
/// tinted icon squares, keycaps, one purple accent, and green / amber / red only for state.
enum EW {
    static let accent      = Color(hex: 0x7C5CFF)
    static let accentFill  = Color(hex: 0x6C49EC)
    static let accentDeep  = Color(hex: 0x5A3EE4)
    static let accentText  = adaptive(light: 0x5934BE, dark: 0xC3B5FF)
    static let pink        = adaptive(light: 0x9F2868, dark: 0xFF94CC)
    static let blue        = adaptive(light: 0x245CA6, dark: 0x8CC0FF)
    static let good        = adaptive(light: 0x11633D, dark: 0x3DD68C)
    static let warn        = adaptive(light: 0x855000, dark: 0xF0B04A)
    static let bad         = adaptive(light: 0xB72E2E, dark: 0xF2766B)
    static let text        = adaptive(light: 0x211D2E, dark: 0xF1EEF8)
    static let dim         = adaptive(light: 0x595269, dark: 0xB6B0C6)
    static let faint       = adaptive(light: 0x625B73, dark: 0xA39CB5)
    // Opaque foundations: a bright window behind the popover must never wash out its text.
    static let panelFill   = adaptive(light: 0xFBFAFE, dark: 0x1E1C26)
    static let cardFill    = adaptive(light: 0xF0EDF6, dark: 0x292632)
    static let controlFill = adaptive(light: 0xE5DFEF, dark: 0x35303F)
    static let cardStroke  = adaptive(light: 0xD8D1E4, dark: 0x474051)
    static let panelWidth: CGFloat = 336

    private static func adaptive(light: UInt32, dark: UInt32) -> Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            let isDark = appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua
            let hex = isDark ? dark : light
            return NSColor(srgbRed: CGFloat((hex >> 16) & 255) / 255,
                           green: CGFloat((hex >> 8) & 255) / 255,
                           blue: CGFloat(hex & 255) / 255, alpha: 1)
        })
    }
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(.sRGB,
                  red: Double((hex >> 16) & 0xFF) / 255,
                  green: Double((hex >> 8) & 0xFF) / 255,
                  blue: Double(hex & 0xFF) / 255,
                  opacity: opacity)
    }
}

// MARK: - Surfaces

struct CardModifier: ViewModifier {
    var radius: CGFloat = 12
    func body(content: Content) -> some View {
        content
            .background(EW.cardFill, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: radius, style: .continuous).strokeBorder(EW.cardStroke))
    }
}

extension View {
    func ewCard(radius: CGFloat = 12) -> some View { modifier(CardModifier(radius: radius)) }

    /// The dark glass used by the Bar, reader card and standalone panels.
    func ewGlass(radius: CGFloat = 16) -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(Color(hex: 0x1A1921, opacity: 0.96))
            )
            .overlay(RoundedRectangle(cornerRadius: radius, style: .continuous).strokeBorder(Color.white.opacity(0.09)))
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .shadow(color: .black.opacity(0.45), radius: 30, y: 16)
    }
}

// MARK: - Small parts

struct Keycap: View {
    let text: String
    var size: CGFloat = 11
    var onAccent = false

    var body: some View {
        Text(text)
            .font(.system(size: size, weight: .semibold))
            .tracking(0.3)
            .foregroundStyle(onAccent ? Color.white : EW.text)
            .padding(.horizontal, size * 0.55)
            .padding(.vertical, size * 0.3)
            .background(onAccent ? Color.black.opacity(0.12) : EW.controlFill, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous).strokeBorder(onAccent ? Color.white.opacity(0.35) : EW.cardStroke))
            .accessibilityLabel("Shortcut \(Self.spoken(text))")
    }

    /// "⌥⌘T" → "Option Command T", so VoiceOver reads shortcuts properly.
    static func spoken(_ s: String) -> String {
        let names: [Character: String] = ["⌃": "Control", "⌥": "Option", "⇧": "Shift", "⌘": "Command",
                                          "↩": "Return", "↑": "Up", "↓": "Down"]
        return s.map { names[$0] ?? String($0) }.joined(separator: " ")
    }
}

struct IconSquare: View {
    let symbol: String
    let tint: Color
    var size: CGFloat = 24

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: size * 0.5, weight: .semibold))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(tint.opacity(0.2), in: RoundedRectangle(cornerRadius: size * 0.3, style: .continuous))
            .accessibilityHidden(true)
    }
}

struct StatusDot: View {
    let color: Color
    var body: some View {
        Circle().fill(color).frame(width: 7, height: 7)
            .shadow(color: color.opacity(0.8), radius: 4)
            .accessibilityHidden(true)
    }
}

/// The app icon drawn in vectors: purple tile, white speech bubble, "A". Crisp at any size and
/// identical in the panel, the HUD and the welcome window.
struct AppGlyph: View {
    var size: CGFloat = 34

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                .fill(LinearGradient(colors: [Color(hex: 0x8A6BFF), Color(hex: 0x6D4BF0)],
                                     startPoint: .top, endPoint: .bottom))
                .overlay(RoundedRectangle(cornerRadius: size * 0.24, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.25), lineWidth: 0.5))
            BubbleShape()
                .fill(.white)
                .frame(width: size * 0.6, height: size * 0.56)
                .offset(y: size * 0.03)
            Text("A")
                .font(.system(size: size * 0.3, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: 0x6D4BF0))
                .offset(y: -size * 0.02)
        }
        .frame(width: size, height: size)
        .shadow(color: Color(hex: 0x6D4BF0).opacity(0.35), radius: size * 0.12, y: size * 0.05)
        .accessibilityHidden(true)
    }
}

/// Rounded rectangle with a small tail at the bottom left.
struct BubbleShape: Shape {
    func path(in r: CGRect) -> Path {
        let body = CGRect(x: r.minX, y: r.minY, width: r.width, height: r.height * 0.8)
        var p = Path(roundedRect: body, cornerRadius: r.width * 0.24, style: .continuous)
        p.move(to: CGPoint(x: r.minX + r.width * 0.2, y: body.maxY - 1))
        p.addLine(to: CGPoint(x: r.minX + r.width * 0.18, y: r.maxY))
        p.addLine(to: CGPoint(x: r.minX + r.width * 0.42, y: body.maxY - 1))
        p.closeSubpath()
        return p
    }
}

struct Wordmark: View {
    var size: CGFloat = 14
    var body: some View {
        Text("Easy Write")
            .font(.system(size: size, weight: .bold))
            .foregroundStyle(LinearGradient(colors: [EW.accentText, EW.pink], startPoint: .leading, endPoint: .trailing))
    }
}

/// Formal · Informal · Natural, as the studio's capsule segmented control.
struct ToneControl: View {
    @Binding var tone: Tone
    var lang: Lang?

    var body: some View {
        HStack(spacing: 2) {
            ForEach(Tone.allCases) { t in
                Button { tone = t } label: {
                    HStack(spacing: 4) {
                        Text(t.title)
                        if let lang, let p = t.pronoun(in: lang) {
                            Text(p).foregroundStyle(tone == t ? Color.white : EW.faint)
                        }
                    }
                    .font(.system(size: 11.5, weight: tone == t ? .semibold : .regular))
                    .foregroundStyle(tone == t ? Color.white : EW.dim)
                    .frame(maxWidth: .infinity, minHeight: 24)
                    .background {
                        if tone == t {
                            RoundedRectangle(cornerRadius: 6, style: .continuous).fill(EW.accentFill)
                                .shadow(color: EW.accent.opacity(0.5), radius: 4, y: 1)
                        }
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(t.title) tone")
                .accessibilityAddTraits(tone == t ? .isSelected : [])
            }
        }
        .padding(2)
        .background(EW.controlFill, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .animation(.easeOut(duration: 0.15), value: tone)
    }
}

struct EWButtonStyle: ButtonStyle {
    enum Kind { case primary, ghost }
    var kind: Kind = .ghost

    func makeBody(configuration: Configuration) -> some View {
        StyledButtonBody(configuration: configuration, kind: kind)
    }

    private struct StyledButtonBody: View {
        let configuration: ButtonStyleConfiguration
        let kind: Kind
        @Environment(\.isEnabled) private var isEnabled

        var body: some View {
            configuration.label
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(kind == .primary ? Color.white : EW.text)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(kind == .primary ? EW.accentFill : EW.controlFill)
                )
                .overlay(RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(kind == .primary ? Color.white.opacity(0.2) : EW.cardStroke))
                .shadow(color: kind == .primary ? EW.accent.opacity(0.45) : .clear, radius: 7, y: 3)
                .opacity(isEnabled ? (configuration.isPressed ? 0.85 : 1) : 0.4)
        }
    }
}

struct IconButton: View {
    let symbol: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: symbol)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(EW.text)
                .frame(width: 26, height: 26)
                .background(EW.controlFill, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 7, style: .continuous).strokeBorder(EW.cardStroke))
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(label)
        .accessibilityLabel(label)
    }
}

/// Moving highlight used while the model is working.
struct Shimmer: View {
    var width: CGFloat = 54
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var phase: CGFloat = -1

    var body: some View {
        Capsule()
            .fill(EW.accent.opacity(0.28))
            .overlay {
                if !reduceMotion {
                    GeometryReader { g in
                        Capsule()
                            .fill(LinearGradient(colors: [.clear, EW.accentText, .clear], startPoint: .leading, endPoint: .trailing))
                            .frame(width: g.size.width * 0.6)
                            .offset(x: phase * g.size.width)
                    }
                    .clipShape(Capsule())
                }
            }
            .frame(width: width, height: 6)
            .onAppear {
                guard !reduceMotion else { return }
                withAnimation(.linear(duration: 1.1).repeatForever(autoreverses: false)) { phase = 1.2 }
            }
            .accessibilityLabel("Working")
    }
}

/// Small "DE" style language code badge.
struct LangBadge: View {
    let code: String
    var body: some View {
        Text(code.uppercased())
            .font(.system(size: 9.5, weight: .bold))
            .foregroundStyle(.white)
            .padding(.horizontal, 4).padding(.vertical, 2)
            .background(EW.accentFill, in: RoundedRectangle(cornerRadius: 4, style: .continuous))
            .accessibilityHidden(true)
    }
}
