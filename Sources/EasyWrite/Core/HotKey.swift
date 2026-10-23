import Carbon
import Foundation

/// Minimal global hot-key registration via Carbon (works system-wide).
final class HotKeyCenter {
    static let shared = HotKeyCenter()

    private var handlers: [UInt32: () -> Void] = [:]
    private var refs: [UInt32: EventHotKeyRef] = [:]
    private var nextID: UInt32 = 1
    private var installed = false

    func register(keyCode: UInt32, modifiers: UInt32, action: @escaping () -> Void) {
        installHandlerIfNeeded()
        let id = nextID
        nextID += 1
        handlers[id] = action

        let hotKeyID = EventHotKeyID(signature: fourCharCode("EWRT"), id: id)
        var ref: EventHotKeyRef?
        let status = RegisterEventHotKey(keyCode, modifiers, hotKeyID,
                                         GetEventDispatcherTarget(), 0, &ref)
        if status == noErr, let ref = ref {
            refs[id] = ref
        }
    }

    func unregisterAll() {
        for ref in refs.values { UnregisterEventHotKey(ref) }
        refs.removeAll()
        handlers.removeAll()
        nextID = 1
    }

    fileprivate func fire(_ id: UInt32) { handlers[id]?() }

    private func installHandlerIfNeeded() {
        guard !installed else { return }
        installed = true
        var spec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                 eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetEventDispatcherTarget(), hotKeyHandler, 1, &spec, nil, nil)
    }
}

private func fourCharCode(_ s: String) -> OSType {
    var result: OSType = 0
    for ch in s.utf8.prefix(4) { result = (result << 8) + OSType(ch) }
    return result
}

private func hotKeyHandler(_ next: EventHandlerCallRef?,
                           _ event: EventRef?,
                           _ userData: UnsafeMutableRawPointer?) -> OSStatus {
    var hkID = EventHotKeyID()
    let err = GetEventParameter(event,
                                EventParamName(kEventParamDirectObject),
                                EventParamType(typeEventHotKeyID),
                                nil,
                                MemoryLayout<EventHotKeyID>.size,
                                nil,
                                &hkID)
    if err == noErr {
        let id = hkID.id
        DispatchQueue.main.async { HotKeyCenter.shared.fire(id) }
    }
    return noErr
}
