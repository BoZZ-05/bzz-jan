import AppKit
import SwiftUI

class FloatingPanel: NSPanel {
    init(contentRect: NSRect, backing: NSWindow.BackingStoreType, defer flag: Bool) {
        // NSPanel designated initializer requires styleMask
        super.init(contentRect: contentRect, styleMask: [.borderless, .fullSizeContentView], backing: backing, defer: flag)
        
        // We can set additional style masks here if needed, but the init above sets the base.
        // .nonresizable is not a valid enum case; just don't include .resizable.
        // self.styleMask = [.borderless, .fullSizeContentView] 
        
        self.isFloatingPanel = true
        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        self.isMovableByWindowBackground = true // Allow dragging by background
        self.backgroundColor = .clear
        self.hasShadow = true
    }
    
    // Allow the panel to become key window so it can receive input
    override var canBecomeKey: Bool {
        return true
    }
    
    override var canBecomeMain: Bool {
        return true
    }
}
