import AppKit

/// Formats key codes + Carbon modifier masks into readable shortcut strings (e.g. ⌥⌘T),
/// and converts NSEvent modifier flags to Carbon masks for recording.
enum KeyDisplay {
    static let cmd: UInt32 = 256, option: UInt32 = 2048, control: UInt32 = 4096, shift: UInt32 = 512

    static let keyNames: [UInt32: String] = [
        0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X", 8: "C", 9: "V",
        11: "B", 12: "Q", 13: "W", 14: "E", 15: "R", 16: "Y", 17: "T", 31: "O", 32: "U",
        34: "I", 35: "P", 37: "L", 38: "J", 40: "K", 45: "N", 46: "M",
        18: "1", 19: "2", 20: "3", 21: "4", 22: "6", 23: "5", 25: "9", 26: "7", 28: "8", 29: "0",
        24: "=", 27: "-", 30: "]", 33: "[", 39: "'", 41: ";", 42: "\\", 43: ",", 44: "/", 47: ".", 50: "`",
        49: "Space", 36: "Return", 48: "Tab", 51: "Delete", 53: "Esc",
        123: "←", 124: "→", 125: "↓", 126: "↑",
        122: "F1", 120: "F2", 99: "F3", 118: "F4", 96: "F5", 97: "F6",
        98: "F7", 100: "F8", 101: "F9", 109: "F10", 103: "F11", 111: "F12",
    ]

    static func keyLabel(_ code: UInt32) -> String { keyNames[code] ?? "·" }

    static func modifierString(_ m: UInt32) -> String {
        var s = ""
        if m & control != 0 { s += "⌃" }
        if m & option  != 0 { s += "⌥" }
        if m & shift   != 0 { s += "⇧" }
        if m & cmd     != 0 { s += "⌘" }
        return s
    }

    static func string(keyCode: UInt32, modifiers: UInt32) -> String {
        modifierString(modifiers) + keyLabel(keyCode)
    }

    static func carbonModifiers(from f: NSEvent.ModifierFlags) -> UInt32 {
        var m: UInt32 = 0
        if f.contains(.command) { m |= cmd }
        if f.contains(.option)  { m |= option }
        if f.contains(.control) { m |= control }
        if f.contains(.shift)   { m |= shift }
        return m
    }
}
