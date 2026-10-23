import AppKit
import Foundation

/// "From first coffee to lights-out" — the OneKapisch studio, drawn as a day.
///
/// This is the cross-app standard block (spec: `docs/STUDIO-BLOCK.md` in the Tokens 4
/// Breakfast repo). Every OneKapisch app renders the SAME strip, the studio's apps as stops on
/// a dawn-to-dusk timeline matching onekapisch.com's layout, and only the "YOU ARE HERE" glow
/// moves to whichever app the user is standing in. The repetition across apps is the point:
/// one artifact, seen everywhere, reads as a studio rather than a pile of side projects.
///
/// Pure and clock-free so the roster, the slot geometry and the tracking URLs are all testable
/// without a view (see `SelfTest.studio()`).
enum StudioDay {

    struct Stop: Equatable, Identifiable {
        /// Site slug; doubles as `target_product` in tracking URLs.
        let id: String
        /// "09:30" — display string, shown with tabular figures.
        let time: String
        let name: String
        /// Short platform note under the name ("macOS", "iOS · Android").
        let platform: String
        /// One-line pitch, swapped into the header sub-line on hover.
        let tagline: String
        /// Tile image. Every stop ships the official studio icon, pre-trimmed and
        /// squircle-masked by `docs/tools/make-studio-icons.py`, so all seven tiles share one
        /// shape and weight.
        let imageName: String
        /// Product site, bare — tracking params are appended by `url(for:site:)`.
        let site: String
    }

    /// The published day, mirroring onekapisch.com's timeline order and times. Byte-identical
    /// with every other OneKapisch app: when the site's day changes, change it everywhere.
    static let stops: [Stop] = [
        Stop(id: "tokens-4-breakfast", time: "07:10",
             name: "Tokens 4 Breakfast", platform: "macOS",
             tagline: String(localized: "AI usage, spend and limits — live in the menu bar."),
             imageName: "studio_icon_t4b", site: "https://www.tokens4breakfast.app"),
        Stop(id: "mac-4-breakfast", time: "09:30",
             name: "Mac 4 Breakfast", platform: "macOS",
             tagline: String(localized: "Your Mac’s battery, beautifully understood."),
             imageName: "studio_icon_m4b", site: "https://www.mac4breakfast.app"),
        Stop(id: "lumel", time: "12:00",
             name: "Lumel", platform: "macOS",
             tagline: String(localized: "Brighter than macOS allows. Darker than its minimum."),
             imageName: "studio_icon_lumel", site: "https://getlumel.app"),
        Stop(id: "skylocation", time: "14:40",
             name: "SkyLocation", platform: "iOS · Android",
             tagline: String(localized: "Know where you are — without internet or signal."),
             imageName: "studio_icon_sky", site: "https://www.skylocation.app"),
        Stop(id: "clip-4-breakfast", time: "18:20",
             name: "Clip 4 Breakfast", platform: "macOS",
             tagline: String(localized: "The clipboard manager that never slows your Mac down."),
             imageName: "studio_icon_clip", site: "https://clip4breakfast.app"),
        Stop(id: "easy-write", time: "20:15",
             name: "Easy Write", platform: "macOS",
             tagline: String(localized: "Translate and rewrite text anywhere on your Mac, on-device."),
             imageName: "studio_icon_easywrite", site: "https://github.com/onekapisch/easy-write"),
    ]

    /// This app's slug — where the glow sits. The one line each app changes when adopting.
    static let currentID = "easy-write"

    /// The sub-line shown when nothing is hovered.
    static let defaultSubline = String(localized: "Six apps, one standard: privacy-first, no accounts, built in Germany.")

    /// What the trailing dashed slot says when hovered.
    static let moreSubline = String(localized: "Chime · Minimizer · Unfold AI · Tank Alert · Nudge · Models 4 Breakfast, and more.")

    /// Stops are spaced EVENLY, one per slot, with a final slot for "much more". Placing them
    /// proportionally to their clock times looked like a layout bug.
    static var slotCount: Int { stops.count + 1 }

    /// Centre of a slot, as a fraction of the strip's width.
    static func fraction(forSlot slot: Int) -> Double {
        (Double(slot) + 0.5) / Double(slotCount)
    }

    /// The trailing "and much more" slot.
    static var moreFraction: Double { fraction(forSlot: stops.count) }

    /// Outbound link carrying the SAME attribution scheme onekapisch.com uses for its own
    /// cross-links, so a click in an app and a click on the site land in one analytics language.
    static func url(for target: String, site: String) -> URL? {
        var comps = URLComponents(string: site)
        comps?.queryItems = [
            URLQueryItem(name: "source_product", value: currentID),
            URLQueryItem(name: "surface", value: "about-day-strip"),
            URLQueryItem(name: "target_product", value: target),
            URLQueryItem(name: "campaign", value: "studio-network"),
            URLQueryItem(name: "placement_version", value: "1"),
        ]
        return comps?.url
    }

    /// The studio home link, same scheme.
    static var studioURL: URL? {
        url(for: "onekapisch", site: "https://www.onekapisch.com")
    }

    /// The stop the user is standing in, if the roster and `currentID` agree.
    static var currentStop: Stop? { stops.first { $0.id == currentID } }

    /// Easy Write is a Swift package rather than an Xcode project, so the tiles ship as plain
    /// PNGs in Contents/Resources instead of an asset catalog. Dev runs from the build folder
    /// read them straight from the checkout.
    @MainActor static func image(_ name: String) -> NSImage? {
        if let cached = cache[name] { return cached }
        var image = NSImage(named: name)
        if image == nil {
            let repo = URL(fileURLWithPath: #filePath)      // …/Sources/EasyWrite/Core/StudioDay.swift
                .deletingLastPathComponent().deletingLastPathComponent()
                .deletingLastPathComponent().deletingLastPathComponent()
            image = NSImage(contentsOf: repo.appendingPathComponent("Resources/Studio/\(name).png"))
        }
        cache[name] = image
        return image
    }

    @MainActor private static var cache: [String: NSImage] = [:]
}
