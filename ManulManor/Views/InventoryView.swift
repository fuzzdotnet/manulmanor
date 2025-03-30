import SwiftUI

struct InventoryView: View {
    @EnvironmentObject var viewModel: ManulViewModel
    @State private var selectedCategory: Item.ItemType = .food
    @State private var draggedItem: Item?
    @State private var isDragging = false
    @State private var dragPosition = CGPoint(x: 0, y: 0)
    
    // Get items filtered by category and owned status
    var filteredItems: [Item] {
        viewModel.inventory.filter { item in
            item.type == selectedCategory && item.isPurchased
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
                        ItemView(item: item)
                            .position(position)
                            .onTapGesture {
                                viewModel.removeItem(item)
                            }
                    }
                }
                
                // Show the dragged item
                if let item = draggedItem, isDragging {
                    ItemView(item: item)
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
                        ItemView(item: item)
                            .onTapGesture {
                                startDragging(item)
                            }
                    }
                }
                .padding()
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
    let item: Item
    
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