import ApplicationServices
import Carbon

class PasteService {
    static func pasteToActiveApp() {
        // 1. Create Cmd key events
        let source = CGEventSource(stateID: .hidSystemState)
        
        let cmdKey: CGKeyCode = 0x37 // kVK_Command
        let vKey: CGKeyCode = 0x09    // kVK_ANSI_V
        
        // Cmd Down
        guard let cmdDown = CGEvent(keyboardEventSource: source, virtualKey: cmdKey, keyDown: true),
              let vDown = CGEvent(keyboardEventSource: source, virtualKey: vKey, keyDown: true),
              let vUp = CGEvent(keyboardEventSource: source, virtualKey: vKey, keyDown: false),
              let cmdUp = CGEvent(keyboardEventSource: source, virtualKey: cmdKey, keyDown: false) else {
            print("Error: Failed to create paste events")
            return
        }
        
        // Set flags
        vDown.flags = .maskCommand
        vUp.flags = .maskCommand
        
        // Post events
        cmdDown.post(tap: .cghidEventTap)
        vDown.post(tap: .cghidEventTap)
        vUp.post(tap: .cghidEventTap)
        cmdUp.post(tap: .cghidEventTap)
        
        print("Paste events posted")
    }
}
