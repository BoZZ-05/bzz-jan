import Foundation

struct ClipboardItem: Identifiable, Codable, Equatable {
    let id: UUID
    let content: String
    let date: Date
    var isPinned: Bool
    // Type can be extended later (image, file, etc.)
    
    init(content: String, date: Date = Date(), isPinned: Bool = false) {
        self.id = UUID()
        self.content = content
        self.date = date
        self.isPinned = isPinned
    }
}
