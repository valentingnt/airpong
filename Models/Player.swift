import Foundation

struct Player: Identifiable {
    let id: UUID
    var name: String
    
    init(name: String) {
        self.id = UUID()
        self.name = name
    }
}
