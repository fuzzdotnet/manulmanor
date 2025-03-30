import SwiftUI

struct ShopItemView: View {
    @EnvironmentObject var viewModel: ManulViewModel
    let item: Item
    let isLocked: Bool
    let isPurchased: Bool
    let canAfford: Bool
    let action: () -> Void
    
    var body: some View {
        VStack {
            // Item image (using placeholder)
            ZStack {
                Rectangle()
                    .fill(Color.white)
                    .cornerRadius(15)
                    .aspectRatio(1.0, contentMode: .fit)
                    .shadow(radius: 2)
                
                Image(systemName: iconFor(item))
                    .font(.system(size: 50))
                    .foregroundColor(colorFor(item: item))
                
                // Locked overlay
                if isLocked {
                    ZStack {
                        Rectangle()
                            .fill(Color.black.opacity(0.5))
                            .cornerRadius(15)
                        
                        VStack {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 30))
                                .foregroundColor(.white)
                            
                            Text("Level \(item.unlockLevel)")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.top, 5)
                        }
                    }
                }
                
                // Purchased badge for non-consumable items
                if isPurchased && !item.isConsumable {
                    VStack {
                        HStack {
                            Spacer()
                            
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.green)
                                .background(Circle().fill(Color.white).frame(width: 22, height: 22))
                                .padding(8)
                        }
                        
                        Spacer()
                    }
                }
                
                // Quantity badge for consumable items
                if item.isConsumable && isPurchased {
                    let quantity = viewModel.getItemQuantity(item.id)
                    if quantity > 0 || item.id == "food_grasshoppers" {
                        VStack {
                            HStack {
                                Spacer()
                                
                                Text(item.id == "food_grasshoppers" ? "∞" : "\(quantity)")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .background(Circle().fill(Color.orange))
                                    .padding(8)
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
            
            // Item details
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(item.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .frame(minHeight: 36) // Give more space for description
                
                // Price and buy button
                HStack {
                    // Price tag
                    HStack(spacing: 3) {
                        Image(systemName: "dollarsign.circle.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                        
                        Text("\(item.price)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                    // Buy button - different text for consumables
                    Button(action: action) {
                        Text(buttonText)
                            .font(.caption)
                            .fontWeight(.bold)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(buttonColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .disabled(isLocked || (!canAfford) || (!item.isConsumable && isPurchased))
                }
            }
            .padding(10)
            .background(Color.white)
            .cornerRadius(15)
        }
        .frame(minHeight: 220) // Increased height to accommodate more text
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 3)
    }
    
    var buttonText: String {
        if item.isConsumable {
            return isPurchased ? "Buy More" : "Buy"
        } else {
            return isPurchased ? "Owned" : "Buy"
        }
    }
    
    var buttonColor: Color {
        if !item.isConsumable && isPurchased {
            return .gray
        } else if isLocked || !canAfford {
            return .gray.opacity(0.7)
        } else {
            return .blue
        }
    }
} 