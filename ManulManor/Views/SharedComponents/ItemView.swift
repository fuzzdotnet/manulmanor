import SwiftUI

struct ItemView: View {
    @EnvironmentObject var viewModel: ManulViewModel
    let item: Item
    let showQuantity: Bool
    
    var body: some View {
        VStack {
            // In a real app, this would use actual item images
            // Using system images as placeholders
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.white)
                    .frame(width: 70, height: 70)
                    .shadow(radius: 2)
                
                Image(systemName: iconFor(item))
                    .font(.system(size: 40))
                    .foregroundColor(colorFor(item: item))
                
                // Show quantity badge for consumable items
                if showQuantity {
                    let quantity = item.id == "food_grasshoppers" ? 
                        "∞" : "\(viewModel.getItemQuantity(item.id))"
                    
                    VStack {
                        HStack {
                            Spacer()
                            
                            Text(quantity)
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(.white)
                                .padding(5)
                                .background(Circle().fill(Color.orange))
                                .padding(5)
                        }
                        
                        Spacer()
                    }
                }
            }
            
            Text(item.name)
                .font(.caption)
                .foregroundColor(.primary)
                .lineLimit(1)
        }
        .frame(width: 80, height: 100)
    }
} 