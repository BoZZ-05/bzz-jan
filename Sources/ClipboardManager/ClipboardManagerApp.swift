import SwiftUI
import AppKit
import Combine

@main
struct ClipboardManagerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var panel: FloatingPanel!
    var clipboardMonitor = ClipboardMonitor()
    var hotKeyService = HotKeyService()
    var cancellables = Set<AnyCancellable>()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("Clipboard Manager started! Look for the icon in your menu bar.")
        
        // Check for Accessibility Permissions
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let accessEnabled = AXIsProcessTrustedWithOptions(options)
        if !accessEnabled {
            print("Accessibility not enabled. Please enable it in System Settings.")
            DispatchQueue.main.async {
                let alert = NSAlert()
                alert.messageText = "需要辅助功能权限"
                alert.informativeText = "请在“系统设置 -> 隐私与安全性 -> 辅助功能”中授予 ClipboardManager 权限，否则无法自动粘贴。\n\n如果您之前已添加，请先删除旧条目再重新添加。"
                alert.alertStyle = .warning
                alert.addButton(withTitle: "打开设置")
                alert.addButton(withTitle: "取消")
                let response = alert.runModal()
                if response == .alertFirstButtonReturn {
                    if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                        NSWorkspace.shared.open(url)
                    }
                }
            }
        }

        // Hide dock icon
        NSApp.setActivationPolicy(.accessory)
        
        // Setup Status Bar Item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem?.button {
            // Use a standard symbol that exists on macOS 13
            button.image = NSImage(systemSymbolName: "doc.on.clipboard", accessibilityDescription: "Clipboard Manager")
            button.action = #selector(togglePanel)
        }
        
        // Start Monitoring
        clipboardMonitor.startMonitoring()
        
        // Setup Panel
        createPanel()
        
        // Setup HotKey
        hotKeyService.toggleWindowSubject
            .sink { [weak self] in
                self?.togglePanel()
            }
            .store(in: &cancellables)
            
        // Close panel when it loses focus (clicked outside)
        // Only close if we are not pasting
        NotificationCenter.default.publisher(for: NSWindow.didResignKeyNotification, object: panel)
             .sink { [weak self] _ in
                 // Check if we are currently in the middle of a paste operation
                 // If so, we might not want to close immediately, OR we want to close if user clicked elsewhere
                 // User requirement: "If I drag it to another location, then click back to input box, it closes" -> "It should not close unless I double click outside"
                 // Wait, standard behavior is click outside -> close.
                 // User says: "Drag to other place. Click back to input box -> closes." (This is normal "resign key")
                 // "I want: Drag to other place. Click somewhere else -> NOT close. Only double click outside closes?"
                 // Implementing "Double click outside to close" is hard because we don't capture events outside our window.
                 // 
                 // Alternative interpretation:
                 // "I dragged it away. Then I clicked my input box to type. The window closed. I didn't want it to close."
                 // This means the window should be "Floating" and NOT close on resign key.
                 // But then how to close it? "Double click outside" is impossible to detect easily without a global monitor.
                 // Maybe "Close button" or "HotKey again" or "Click outside" (but standard click).
                 
                 // Let's try to just DISABLE "Close on Resign Key" completely.
                 // The user said: "unless I click outside... it closes, otherwise it should not proactively close"
                 // BUT in the latest prompt: "I click back to input box, it triggers cancel... I want: click other place -> NOT cancel. Only double click outside -> cancel"
                 
                 // If we disable "Close on Resign Key", the window stays open until:
                 // 1. User clicks a close button (we can add one)
                 // 2. User presses HotKey again
                 // 3. User pastes something (but user said "after paste, window closes" was bad too, so we fixed that)
                 
                 // Let's disable auto-close on resign key for now as requested.
                 // self?.closePanel()
             }
             .store(in: &cancellables)
    }
    
    func createPanel() {
        let contentView = HistoryView(clipboardMonitor: clipboardMonitor) { [weak self] item in
            self?.pasteItem(item)
        }
        
        // Size
        let contentRect = NSRect(x: 0, y: 0, width: 300, height: 400)
        
        panel = FloatingPanel(contentRect: contentRect, backing: .buffered, defer: false)
        panel.contentView = NSHostingView(rootView: contentView)
        panel.center() // Initial position
    }
    
    @objc func togglePanel() {
        // Only close if the panel is currently visible, is the key window, and the app is active.
        // This handles the case where the user switches to another app (making this app inactive)
        // but the panel remains "visible" in the background. In that case, we want to bring it front, not close it.
        if panel.isVisible && panel.isKeyWindow && NSApp.isActive {
            closePanel()
        } else {
            showPanel()
        }
    }
    
    func showPanel(atMouse: Bool = true) {
        if atMouse {
            // Move to mouse position
            let mouseLocation = NSEvent.mouseLocation
            // Adjust for panel size
            let panelSize = panel.frame.size
            // Screen coordinates: (0,0) is bottom-left
            
            // Offset to avoid covering the caret/mouse position immediately
            // Show slightly to the right and below, or just below
            var x = mouseLocation.x
            // Move slightly to the right to clear the cursor
            x += 20
            
            var y = mouseLocation.y - (panelSize.height) // Show below cursor
            
            // Add some padding so it's not right under the cursor tip
            y -= 20
            
            // Ensure within screen bounds (simplified)
            if let screen = NSScreen.main {
                let frame = screen.visibleFrame
                x = max(frame.minX, min(x, frame.maxX - panelSize.width))
                y = max(frame.minY, min(y, frame.maxY - panelSize.height))
            }
            
            panel.setFrameOrigin(NSPoint(x: x, y: y))
        }
        
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
    }
        
    func closePanel() {
        panel.orderOut(nil)
        // Deactivate app to return focus to previous app
        NSApp.hide(nil) 
    }
    
    func pasteItem(_ item: ClipboardItem) {
        print("Pasting item: \(item.content)")
        // 1. Write to pasteboard
        clipboardMonitor.addToPasteboard(item: item)
        
        // 2. Yield focus to previous app
        // We MUST hide the app to ensure focus returns to the previous application immediately.
        NSApp.hide(nil)
        
        // 3. Simulate Paste
        // Add a small delay to ensure focus has returned
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            print("Simulating Cmd+V")
            PasteService.pasteToActiveApp()
            
            // 4. Show panel again after pasting
            // The user wants the window to stay open (or reappear) after pasting
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.showPanel(atMouse: false)
            }
        }
    }
}
