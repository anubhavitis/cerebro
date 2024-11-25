import Foundation

struct Note: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let path: URL
    var content: String
    var modifiedDate: Date

    init(id: UUID = UUID(), name: String, path: URL, content: String, modifiedDate: Date) {
        self.id = id
        self.name = name
        self.path = path
        self.content = content
        self.modifiedDate = modifiedDate
    }
}
