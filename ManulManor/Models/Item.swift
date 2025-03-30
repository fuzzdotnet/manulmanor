import Foundation
import SwiftUI

struct Item: Identifiable, Codable, Hashable {
    var id: String
    var name: String
    var description: String
    var price: Int
    var imageName: String
    var type: ItemType
    var unlockLevel: Int
    var isPurchased: Bool = false
    var position: CGPoint? // For placed decorations
    
    enum ItemType: String, Codable, CaseIterable {
        case food
        case toy
        case furniture
        case decoration
        case hat
        case accessory
        
        var displayName: String {
            switch self {
            case .food: return "Food"
            case .toy: return "Toys"
            case .furniture: return "Furniture"
            case .decoration: return "Decorations"
            case .hat: return "Hats"
            case .accessory: return "Accessories"
            }
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id
    }
}

// Extension with sample items
extension Item {
    static let sampleItems: [Item] = [
        Item(id: "food_grasshoppers", name: "Grasshoppers", description: "Common food for your manul - always free", price: 0, imageName: "food_grasshoppers", type: .food, unlockLevel: 1, isPurchased: true),
        Item(id: "food_pika", name: "Pika", description: "A tasty small mammal", price: 15, imageName: "food_pika", type: .food, unlockLevel: 1),
        Item(id: "food_partridge", name: "Partridge", description: "A flavorful bird", price: 30, imageName: "food_partridge", type: .food, unlockLevel: 2),
        Item(id: "food_marmot", name: "Marmot", description: "A favorite high-calorie meal", price: 45, imageName: "food_marmot", type: .food, unlockLevel: 3),
        Item(id: "food_chicken", name: "Chicken", description: "Premium protein source", price: 60, imageName: "food_chicken", type: .food, unlockLevel: 4),
        Item(id: "food_fish", name: "Fish", description: "Super premium food for special occasions", price: 75, imageName: "food_fish", type: .food, unlockLevel: 5),
        
        Item(id: "hat_beanie", name: "Beanie", description: "A cozy hat for cold weather", price: 50, imageName: "hat_beanie", type: .hat, unlockLevel: 2),
        Item(id: "accessory_bowtie", name: "Bow Tie", description: "For formal occasions", price: 40, imageName: "accessory_bowtie", type: .accessory, unlockLevel: 2),
        
        Item(id: "furniture_bed", name: "Cozy Bed", description: "A comfy bed for your manul", price: 100, imageName: "furniture_bed", type: .furniture, unlockLevel: 3),
        Item(id: "decoration_plant", name: "Plant", description: "Adds some nature to the manor", price: 75, imageName: "decoration_plant", type: .decoration, unlockLevel: 3),
        
        Item(id: "toy_ball", name: "Yarn Ball", description: "A fun toy to play with", price: 30, imageName: "toy_ball", type: .toy, unlockLevel: 1, isPurchased: true)
    ]
} 