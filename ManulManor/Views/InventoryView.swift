import SwiftUI

struct InventoryView: View {
    @EnvironmentObject var viewModel: ManulViewModel
    @State private var selectedCategory: Item.ItemType = .food
    @State private var draggedItem: Item?
    @State private var isDragging = false
    @State private var dragPosition = CGPoint(x: 0, y: 0)
    @State private var foodForSheet: Item?
    
    // Get items filtered by category and owned status
    var filteredItems: [Item] {
        viewModel.inventory.filter { item in
            if item.type == selectedCategory {
                if item.isConsumable {
                    // For consumable items, only show if quantity > 0 or it's grasshoppers (always available)
                    return item.id == "food_grasshoppers" || viewModel.getItemQuantity(item.id) > 0
                } else {
                    // For non-consumable items, show if purchased
                    return item.isPurchased
                }
            }
            return false
        }
    }
    
    var body: some View {
        VStack {
            // Header
            Text("Inventory")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            // Category selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(Item.ItemType.allCases, id: \.self) { category in
                        CategoryButton(
                            title: category.displayName,
                            isSelected: category == selectedCategory,
                            action: {
                                selectedCategory = category
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
            
            // Placeable area - in a real implementation this would show the manul's habitat
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 300)
                
                // Display placed items
                ForEach(viewModel.placedItems.filter { $0.type == .furniture || $0.type == .decoration }) { item in
                    if let position = item.position {
                        ItemView(item: item, showQuantity: false)
                            .position(position)
                            .onTapGesture {
                                viewModel.removeItem(item)
                            }
                    }
                }
                
                // Show the dragged item
                if let item = draggedItem, isDragging {
                    ItemView(item: item, showQuantity: false)
                        .position(dragPosition)
                        .opacity(0.7)
                }
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isDragging, let item = draggedItem {
                            isDragging = true
                        }
                        
                        if isDragging {
                            dragPosition = value.location
                        }
                    }
                    .onEnded { value in
                        if let item = draggedItem {
                            if item.type == .furniture || item.type == .decoration {
                                viewModel.placeItem(item, at: value.location)
                            } else if item.type == .hat || item.type == .accessory {
                                // For wearable items, add to manul directly
                                viewModel.wearItem(item)
                            }
                        }
                        
                        draggedItem = nil
                        isDragging = false
                    }
            )
            
            Divider()
            
            // Inventory grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(filteredItems) { item in
                        ItemView(item: item, showQuantity: item.isConsumable)
                            .onTapGesture {
                                handleItemTap(item)
                            }
                    }
                }
                .padding()
            }
        }
        .sheet(item: $foodForSheet) { food in
            FeedConfirmationView(food: food) { confirmed in
                if confirmed {
                    viewModel.feedManul(with: food)
                }
            }
        }
    }
    
    private func handleItemTap(_ item: Item) {
        if item.type == .food {
            // Make sure the food item can be used (has quantity > 0 or is grasshoppers)
            if item.id == "food_grasshoppers" || viewModel.getItemQuantity(item.id) > 0 {
                foodForSheet = item
            } else {
                // Show feedback that item is out of stock
                viewModel.showFeedback("No \(item.name) left in inventory!", interactionType: "info")
            }
        } else if item.type == .furniture || item.type == .decoration {
            // For furniture or decorations, start dragging
            startDragging(item)
        } else if item.type == .hat || item.type == .accessory {
            // For wearable items, toggle wearing
            if viewModel.manul.wearingItems.contains(item.id) {
                viewModel.removeWornItem(item)
            } else {
                viewModel.wearItem(item)
            }
        }
    }
    
    private func startDragging(_ item: Item) {
        self.draggedItem = item
        self.dragPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: 300)
    }
}

struct CategoryButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.3))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(20)
        }
    }
}

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
                
                Image(systemName: itemIcon)
                    .font(.system(size: 40))
                    .foregroundColor(itemColor)
                
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
    
    var itemIcon: String {
        switch item.type {
        case .food:
            return "fork.knife"
        case .toy:
            return "star.fill"
        case .furniture:
            return "bed.double.fill"
        case .decoration:
            return "leaf.fill"
        case .hat:
            return "crown.fill"
        case .accessory:
            return "gift.fill"
        }
    }
    
    var itemColor: Color {
        switch item.type {
        case .food:
            return .orange
        case .toy:
            return .yellow
        case .furniture:
            return .brown
        case .decoration:
            return .green
        case .hat:
            return .purple
        case .accessory:
            return .pink
        }
    }
}

// Feed confirmation view
struct FeedConfirmationView: View {
    @Environment(\.presentationMode) var presentationMode
    let food: Item
    let onConfirm: (Bool) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            Image(systemName: "fork.knife")
                .font(.system(size: 60))
                .foregroundColor(.orange)
                .padding()
            
            Text("Feed \(food.name)?")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(food.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            HStack(spacing: 30) {
                // Cancel button
                Button(action: {
                    onConfirm(false)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Cancel")
                        .font(.headline)
                        .padding()
                        .frame(minWidth: 100)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                }
                
                // Confirm button
                Button(action: {
                    onConfirm(true)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Feed")
                        .font(.headline)
                        .padding()
                        .frame(minWidth: 100)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.top, 20)
        }
        .padding()
    }
} 