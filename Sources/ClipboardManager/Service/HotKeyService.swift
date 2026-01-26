import HotKey
import AppKit
import Combine

class HotKeyService: ObservableObject {
    private var hotKey: HotKey?
    
    // Publish an event when hotkey is pressed
    let toggleWindowSubject = PassthroughSubject<Void, Never>()
    
    init() {
        // Register Cmd + Shift + V
        // Modifiers: command, shift
        // Key: v
        self.hotKey = HotKey(key: .v, modifiers: [.command, .shift])
        
        self.hotKey?.keyDownHandler = { [weak self] in
            print("HotKey Pressed")
            self?.toggleWindowSubject.send()
        }
    }
}
