import Foundation

struct Manul: Codable, Identifiable {
    var id = UUID()
    var name: String
    var level: Int
    var xp: Int
    var hunger: Double  // 0.0 to 1.0, where 1.0 is full
    var hygiene: Double // 0.0 to 1.0, where 1.0 is clean
    var happiness: Double // 0.0 to 1.0, where 1.0 is happy
    var coins: Int
    var lastFed: Date
    var lastCleaned: Date
    var lastInteraction: Date
    var wearingItems: [String] // IDs of items being worn
    
    var mood: Mood {
        let avgStatus = (hunger + hygiene + happiness) / 3.0
        
        if avgStatus >= 0.8 {
            return .happy
        } else if avgStatus >= 0.5 {
            return .neutral
        } else if avgStatus >= 0.2 {
            return .sad
        } else {
            return .unhappy
        }
    }
    
    enum Mood: String, Codable {
        case happy, neutral, sad, unhappy
    }
    
    static func newManul(name: String) -> Manul {
        return Manul(
            name: name,
            level: 1,
            xp: 0,
            hunger: 0.8,
            hygiene: 1.0,
            happiness: 0.9,
            coins: 100,
            lastFed: Date(),
            lastCleaned: Date(),
            lastInteraction: Date(),
            wearingItems: []
        )
    }
} 