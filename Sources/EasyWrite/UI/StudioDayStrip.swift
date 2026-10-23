import SwiftUI
import AppKit

/// The studio's day, drawn as a dawn-to-dusk strip. Cross-app standard block — see
/// `StudioDay` for the model and the spec it follows.
///
/// The STRUCTURE and the copy are identical in every OneKapisch app; the colours belong to the
/// host. Easy Write's are the violet and pink of its icon and wordmark: the track runs from the
/// pink of the wordmark at dawn, through the violet accent, into the deep violet of the Bar card,
/// ending on the hairline used for night.
///
/// Static by design — hover is the only state, so Reduce Motion has nothing to object to.
struct StudioDayStrip: View {
    @State private var hoveredID: String?

    // Seven slots side by side; the Settings detail pane is wide enough for all of them at 78pt.
    private let tile: CGFloat = 38
    private let hereTile: CGFloat = 48
    private let slotWidth: CGFloat = 78

    // One vertical rhythm, shared by every stop AND by the track. Stops are laid out from a
    // common TOP edge rather than centred, so the current app's larger tile can't lift its time
    // above the others. The name block is a fixed two lines for the same reason.
    private let timeRowHeight: CGFloat = 14
    private let tileGap: CGFloat = 9
    private var tileBand: CGFloat { hereTile }
    /// The day passes just UNDER the tiles, so they rest on it (drawn through them, it slices
    /// every icon in half).
    private var trackY: CGFloat { timeRowHeight + tileGap + tileBand + 9 }
    private let nameGap: CGFloat = 16
    private let nameBlock: CGFloat = 28

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            timeline
                .frame(height: trackY + nameGap + nameBlock + 18)
                .padding(.top, 18)
            studioBar
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 12, style: .continuous).fill(Studio.card))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).strokeBorder(Studio.stroke))
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("\(Text("One studio. ").font(.system(size: 14, weight: .semibold)).foregroundStyle(.primary))\(Text("A whole day, covered.").font(.system(size: 14)).foregroundStyle(.secondary))")
            // Hovering a stop swaps its pitch in here.
            Text(hoveredSubline)
                .font(.system(size: 10))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .animation(nil, value: hoveredID)      // a text swap, not motion
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var hoveredSubline: String {
        if hoveredID == "__more" { return StudioDay.moreSubline }
        guard let hoveredID,
              let stop = StudioDay.stops.first(where: { $0.id == hoveredID })
        else { return StudioDay.defaultSubline }
        return "\(stop.name) — \(stop.tagline)"
    }

    // MARK: Timeline

    private var timeline: some View {
        GeometryReader { geo in
            let width = geo.size.width
            ZStack(alignment: .topLeading) {
                LinearGradient(colors: [EW.pink, EW.accent, EW.accentDeep, Studio.stroke],
                               startPoint: .leading, endPoint: .trailing)
                    .frame(height: 2)
                    .clipShape(Capsule())
                    .offset(y: trackY)

                ForEach(Array(StudioDay.stops.enumerated()), id: \.element.id) { index, stop in
                    stopView(stop, isHere: stop.id == StudioDay.currentID)
                        .frame(width: slotWidth)
                        .offset(x: width * StudioDay.fraction(forSlot: index) - slotWidth / 2, y: 0)
                }

                moreStop
                    .frame(width: slotWidth)
                    .offset(x: width * StudioDay.moreFraction - slotWidth / 2, y: 0)
            }
        }
    }

    @ViewBuilder
    private func stopView(_ stop: StudioDay.Stop, isHere: Bool) -> some View {
        let content = VStack(spacing: 0) {
            Text(stop.time)
                .font(.system(size: 10, weight: .medium, design: .monospaced))
                .monospacedDigit()
                .foregroundStyle(isHere ? AnyShapeStyle(Studio.accent) : AnyShapeStyle(.primary))
                .frame(height: timeRowHeight)
            // Fixed-height band: the current app's bigger tile grows INTO the band instead of
            // pushing everything below it out of line with its neighbours.
            tileImage(stop, size: isHere ? hereTile : tile, isHere: isHere)
                .frame(height: tileBand)
                .padding(.top, tileGap)
            Text(stop.name)
                .font(.system(size: isHere ? 11 : 10.5, weight: isHere ? .semibold : .medium))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
                .frame(height: nameBlock, alignment: .top)
                .padding(.top, nameGap)
            if isHere {
                // Allowed to exceed its slot: only one stop carries the pill, so it overhangs
                // empty space rather than a neighbour. Violet takes white text.
                Text("YOU ARE HERE")
                    .font(.system(size: 7, weight: .bold, design: .monospaced))
                    .kerning(0.7)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(.horizontal, 6).padding(.vertical, 2.5)
                    .background(Capsule().fill(
                        LinearGradient(colors: [Color(hex: 0x8A6BFF), EW.accentDeep], startPoint: .top, endPoint: .bottom)))
                    .padding(.top, 4)
            } else {
                Text(stop.platform)
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(.top, 3)
            }
            Spacer(minLength: 0)
        }
        .frame(width: slotWidth, alignment: .top)

        if isHere {
            // The app the user is standing in: lit, and NOT a link. Sending someone to the
            // product page of the product they are inside is an ad, not information.
            content
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(stop.name), this app, \(stop.time) in the studio's day")
        } else {
            Button {
                if let url = StudioDay.url(for: stop.id, site: stop.site) { NSWorkspace.shared.open(url) }
            } label: {
                content.contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .buttonStyle(.plain)
            .onHover { hoveredID = $0 ? stop.id : nil }
            .help(stop.tagline)
            .accessibilityLabel("\(stop.name), \(stop.tagline)")
        }
    }

    /// The tile PNGs are already trimmed and masked to Apple's superellipse, so nothing is
    /// clipped or stroked here: a clip would cut the baked corners, and a border would trace a
    /// different curve than the art. Depth is a shadow, which follows the alpha exactly, and
    /// the current app's glow is the same mechanism.
    @ViewBuilder
    private func tileImage(_ stop: StudioDay.Stop, size: CGFloat, isHere: Bool) -> some View {
        Group {
            if let image = StudioDay.image(stop.imageName) {
                Image(nsImage: image).resizable().interpolation(.high)
            } else {
                Color.clear
            }
        }
        .frame(width: size, height: size)
        .shadow(color: .black.opacity(0.45), radius: 3, y: 1)
        .shadow(color: isHere ? EW.accent.opacity(0.60) : .clear, radius: 10)
        .shadow(color: isHere ? EW.accent.opacity(0.32) : .clear, radius: 20)
    }

    /// The end of the day: everything not on the strip, and a real destination.
    private var moreStop: some View {
        Button {
            if let url = StudioDay.studioURL { NSWorkspace.shared.open(url) }
        } label: {
            VStack(spacing: 0) {
                Text("AND")
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .frame(height: timeRowHeight)
                Text("+")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Studio.accent)
                    .frame(width: tile, height: tile)
                    .overlay(RoundedRectangle(cornerRadius: tile * 0.26, style: .continuous)
                        .strokeBorder(Studio.accent.opacity(0.45), style: StrokeStyle(lineWidth: 1, dash: [3, 3])))
                    .frame(height: tileBand)
                    .padding(.top, tileGap)
                Text("much more")
                    .font(.system(size: 10.5, weight: .medium))
                    .foregroundStyle(Studio.accent)
                    .multilineTextAlignment(.center)
                    .frame(height: nameBlock, alignment: .top)
                    .padding(.top, nameGap)
                Text("see them all")
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(.top, 3)
                Spacer(minLength: 0)
            }
            .frame(width: slotWidth, alignment: .top)
            .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(.plain)
        .onHover { hoveredID = $0 ? "__more" : nil }
        .help("Chime, Minimizer, Unfold AI, Nudge, Models 4 Breakfast and more")
        .accessibilityLabel("And much more — see every OneKapisch product")
    }

    // MARK: Studio bar

    private var studioBar: some View {
        HStack(spacing: 9) {
            Group {
                if let mark = StudioDay.image("studio_icon_onekapisch") {
                    Image(nsImage: mark).resizable().interpolation(.high)
                } else {
                    Color.clear
                }
            }
            .frame(width: 28, height: 28)
            .shadow(color: .black.opacity(0.35), radius: 2, y: 1)
            .accessibilityHidden(true)
            Text("\(Text("OneKapisch").font(.system(size: 11.5, weight: .semibold)).foregroundStyle(.primary))\(Text(" — privacy-first software studio, built in Germany.").font(.system(size: 11.5)).foregroundStyle(.secondary))")
                .lineLimit(1)
                .minimumScaleFactor(0.85)
            Spacer(minLength: 6)
            Button {
                if let url = StudioDay.studioURL { NSWorkspace.shared.open(url) }
            } label: {
                Text("ENTER THE STUDIO ↗")
                    .font(.system(size: 9, weight: .medium, design: .monospaced))
                    .kerning(0.5)
                    .foregroundStyle(Studio.accent)
                    .lineLimit(1)
                    .fixedSize(horizontal: true, vertical: false)
                    .padding(.horizontal, 9).padding(.vertical, 5)
                    .background(RoundedRectangle(cornerRadius: 7).strokeBorder(Studio.accent.opacity(0.45), lineWidth: 1))
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .help("Open onekapisch.com")
        }
        .padding(.top, 12)
        .overlay(alignment: .top) { Rectangle().fill(Studio.stroke).frame(height: 1) }
    }
}

/// The OneKapisch studio, on its own settings page directly below About (per the spec: About
/// is about THIS product, and squeezing the strip underneath it was wrong twice in other apps).
struct StudioSettingsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("THE ONEKAPISCH STUDIO")
                        .font(.system(size: 9.5, weight: .semibold, design: .monospaced))
                        .kerning(1.4)
                        .foregroundStyle(Studio.accent)
                    Text("From first coffee to lights-out.")
                        .font(.system(size: 22, weight: .semibold))
                        .kerning(-0.4)
                        .foregroundStyle(.primary)
                    Text("Privacy-first apps for Mac, iPhone and the web — designed and built in Germany.")
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 2)
                StudioDayStrip()
            }
            .padding(20)
        }
    }
}

/// Colours for surfaces that follow the system appearance (Settings), so the violet stays
/// readable on both light and dark backgrounds.
enum Studio {
    static let accent = Color(nsColor: NSColor(name: nil) { appearance in
        appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            ? NSColor(srgbRed: 0.66, green: 0.60, blue: 1.0, alpha: 1)       // #A898FF
            : NSColor(srgbRed: 0.36, green: 0.25, blue: 0.90, alpha: 1)      // #5B3FE6
    })
    static let card = Color(nsColor: .controlBackgroundColor)
    static let stroke = Color(nsColor: .separatorColor)
}
