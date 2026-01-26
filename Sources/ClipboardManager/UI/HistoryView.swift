import SwiftUI

struct HistoryView: View {
    @ObservedObject var clipboardMonitor: ClipboardMonitor
    var onSelect: (ClipboardItem) -> Void
    
    @State private var hoveredItemId: UUID?
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with Clear All
            HStack {
                Button(action: {
                    clipboardMonitor.clearAll()
                }) {
                    Text("Clear All")
                        .font(.caption)
                }
                
                Spacer()
                
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }) {
                    Image(systemName: "power")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .help("Quit App")
            }
            .padding(8)
            
            ScrollViewReader { proxy in
                List(clipboardMonitor.history) { item in
                    HStack {
                        Text(item.content.trimmingCharacters(in: .whitespacesAndNewlines))
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .foregroundColor(item.isPinned ? .primary : .secondary)
                            .fontWeight(item.isPinned ? .medium : .regular)
                        
                        Spacer()
                        
                        // Action Buttons (Show on hover or if pinned)
                        if hoveredItemId == item.id || item.isPinned {
                            HStack(spacing: 8) {
                                Button(action: {
                                    clipboardMonitor.togglePin(for: item)
                                }) {
                                    Image(systemName: item.isPinned ? "pin.fill" : "pin")
                                        .foregroundColor(item.isPinned ? .orange : .gray)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                Button(action: {
                                    clipboardMonitor.removeItem(item)
                                }) {
                                    Image(systemName: "xmark.circle")
                                        .foregroundColor(.gray)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .contentShape(Rectangle())
                    .padding(.vertical, 4)
                    .onTapGesture(count: 2) {
                        onSelect(item)
                    }
                    .onHover { isHovering in
                        if isHovering {
                            hoveredItemId = item.id
                        } else if hoveredItemId == item.id {
                            hoveredItemId = nil
                        }
                    }
                    .id(item.id) // Important for ScrollViewReader
                }
                .listStyle(PlainListStyle())
                .onChange(of: clipboardMonitor.history) { _ in
                    if let first = clipboardMonitor.history.first {
                        withAnimation {
                            proxy.scrollTo(first.id, anchor: .top)
                        }
                    }
                }
                .onAppear {
                    if let first = clipboardMonitor.history.first {
                        proxy.scrollTo(first.id, anchor: .top)
                    }
                }
            }
        }
        .frame(width: 300, height: 400)
        .background(Color(NSColor.windowBackgroundColor))
    }
}
