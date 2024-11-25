import Foundation

struct JournalEntry: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    var content: String

    init(id: UUID = UUID(), timestamp: Date = Date(), content: String) {
        self.id = id
        self.timestamp = timestamp
        self.content = content
    }
}
