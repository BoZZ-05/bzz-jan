import AppKit
import Combine

class ClipboardMonitor: ObservableObject {
    @Published var history: [ClipboardItem] = []
    
    private let pasteboard = NSPasteboard.general
    private var lastChangeCount: Int
    private var timer: Timer?
    
    init() {
        self.lastChangeCount = pasteboard.changeCount
        loadHistory()
    }
    
    private var historyFileURL: URL? {
        // Use a hidden file in the user's home directory to avoid TCC/Sandbox permission issues with Documents/Application Support
        let homeURL = FileManager.default.homeDirectoryForCurrentUser
        return homeURL.appendingPathComponent(".clipboard_manager_history.json")
    }

    private func saveHistory() {
        guard let url = historyFileURL else { return }
        do {
            let data = try JSONEncoder().encode(history)
            try data.write(to: url)
            print("✅ History saved: \(history.count) items to \(url.path)")
        } catch {
            print("❌ Failed to save history: \(error)")
        }
    }
    
    private func loadHistory() {
        guard let url = historyFileURL else { return }
        print("🔄 Loading history from: \(url.path)")
        do {
            let data = try Data(contentsOf: url)
            let loadedHistory = try JSONDecoder().decode([ClipboardItem].self, from: data)
            self.history = loadedHistory
            print("✅ Loaded \(loadedHistory.count) items.")
        } catch {
            print("⚠️ No history found or failed to load (normal for first run): \(error)")
        }
    }
    
    func startMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.checkPasteboard()
        }
    }
    
    private func checkPasteboard() {
        if pasteboard.changeCount != lastChangeCount {
            lastChangeCount = pasteboard.changeCount
            
            // For now, only handle strings
            if let newString = pasteboard.string(forType: .string) {
                // Check if the item already exists in history to avoid duplicates
                // We should check content, but we need to handle pinning carefully.
                // If existing item is pinned, do we move it to top? Or keep it?
                // Usually, if I copy something already pinned, I might expect it to stay pinned but maybe flash?
                // For simplicity: If it exists, remove old one and add new one to top (preserving pin status if desirable, 
                // but usually "new copy" means "fresh start"). 
                // However, user requirement: "最新复制的数据在最上面".
                
                // Let's check if content exists
                if let existingIndex = history.firstIndex(where: { $0.content == newString }) {
                    // Move to top (re-insert)
                    let existingItem = history[existingIndex]
                    // If existing item is pinned, we want to KEEP it pinned but also maybe show it at top?
                    // Or just update timestamp?
                    // User requirement: "Latest copy at top".
                    
                    // If I copy something that is already pinned, usually I want it to be accessible as "latest".
                    // But duplicates are annoying.
                    // Let's move it to top.
                    let wasPinned = existingItem.isPinned
                    
                    DispatchQueue.main.async {
                        // Remove old one
                        self.history.remove(at: existingIndex)
                        // Insert new one at top
                        let newItem = ClipboardItem(content: newString, isPinned: wasPinned)
                        self.history.insert(newItem, at: 0)
                        self.sortHistory()
                        self.saveHistory()
                    }
                } else {
                    let item = ClipboardItem(content: newString)
                    DispatchQueue.main.async {
                        self.history.insert(item, at: 0)
                        // Limit history size (but don't delete pinned items if possible, or just limit total count)
                        if self.history.count > 50 {
                             // Try to remove last unpinned item
                            if let lastUnpinnedIndex = self.history.lastIndex(where: { !$0.isPinned }) {
                                self.history.remove(at: lastUnpinnedIndex)
                            } else {
                                // All pinned? Force remove last one or increase limit?
                                // Just remove last for safety
                                self.history.removeLast()
                            }
                        }
                        self.sortHistory()
                        self.saveHistory()
                    }
                }
            }
        }
    }
    
    private func sortHistory() {
        // Sort: Pinned first, then by Date descending
        history.sort { (item1, item2) -> Bool in
            if item1.isPinned != item2.isPinned {
                return item1.isPinned // True comes first
            }
            return item1.date > item2.date // Newer comes first
        }
    }
    
    func togglePin(for item: ClipboardItem) {
        if let index = history.firstIndex(where: { $0.id == item.id }) {
            history[index].isPinned.toggle()
            sortHistory()
            saveHistory()
        }
    }
    
    func removeItem(_ item: ClipboardItem) {
        if let index = history.firstIndex(where: { $0.id == item.id }) {
            history.remove(at: index)
            saveHistory()
        }
    }
    
    func clearAll() {
        // Remove all EXCEPT pinned items
        history.removeAll { !$0.isPinned }
        saveHistory()
    }
    
    func addToPasteboard(item: ClipboardItem) {
        pasteboard.clearContents()
        pasteboard.setString(item.content, forType: .string)
        // Update changeCount so we don't re-process it as a "new" external copy immediately
        // This prevents the item from jumping to the top of the list when pasted from history
        self.lastChangeCount = pasteboard.changeCount
    }
}
