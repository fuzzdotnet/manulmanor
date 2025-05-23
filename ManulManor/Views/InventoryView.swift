import SwiftUI

struct InventoryView: View {
    @EnvironmentObject var viewModel: ManulViewModel
    @State private var selectedCategory: Item.ItemType = .toy
    @State private var draggedItem: Item?
    @State private var isDragging = false
    @State private var dragPosition = CGPoint.zero // Use global coordinates for drag position
    @State private var dragOffset = CGPoint.zero // Store the offset from finger to item center
    @State private var habitatFrame: CGRect = .zero // Store the habitat frame
    @State private var trashFrame: CGRect = .zero // Store the trash area frame
    @State private var isOverTrash: Bool = false // Track if drag is over trash

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
    
    // Helper to check if an item is currently worn
    private func isWorn(_ item: Item) -> Bool {
        viewModel.manul.wearingItems.contains(item.id)
    }

    var body: some View {
        ZStack { // Use a ZStack to overlay the dragged item view
            VStack {
                // Header
                Text("Inventory")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity) // Ensure header is centered
                
                // Category selector
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        // Filter out the .food category
                        ForEach(Item.ItemType.allCases.filter { $0 != .food }, id: \.self) { category in
                            CategoryButton(
                                title: category.displayName,
                                isSelected: category == selectedCategory,
                                action: {
                                    selectedCategory = category
                                    
                                    // Reset trash frame and drag state when switching to non-placeable categories
                                    if category != .furniture && category != .decoration {
                                        trashFrame = .zero
                                        isDragging = false
                                        draggedItem = nil
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom)
                
                // Placeable area using GeometryReader to get frame
                GeometryReader { geometry in
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 300)
                        
                        // Add Manul view centered in the habitat
                        ManulView(mood: viewModel.manul.mood, scaleFactor: 0.22)
                            .allowsHitTesting(false)
                        
                        // Display placed items
                        ForEach(viewModel.placedItems.filter { $0.type == .furniture || $0.type == .decoration }) { item in
                            if let position = item.position {
                                PlacedItemView(item: item) // Use a dedicated view for placed items
                                    .position(position)
                                    .gesture(
                                        // Add drag gesture to move already placed items
                                        DragGesture(coordinateSpace: .global)
                                            .onChanged { value in
                                                // Start dragging this item
                                                if !isDragging {
                                                    self.draggedItem = item
                                                    self.isDragging = true
                                                    self.dragPosition = value.location
                                                    
                                                    // Calculate a small offset so the item appears under the finger
                                                    // Use a consistent offset for better user experience
                                                    self.dragOffset = CGPoint(x: 0, y: -30) // Position item a bit above finger
                                                } else {
                                                    self.dragPosition = value.location
                                                }
                                                // Check if over trash area
                                                self.isOverTrash = trashFrame.contains(value.location)
                                            }
                                            .onEnded { value in
                                                if let dragged = self.draggedItem {
                                                    if trashFrame.contains(value.location) {
                                                        // Dropped on trash: remove item
                                                        viewModel.removeItem(dragged)
                                                    } else {
                                                        // Dropped elsewhere: attempt to place in habitat
                                                        let localPosition = CGPoint(
                                                            x: value.location.x - habitatFrame.minX,
                                                            y: value.location.y - habitatFrame.minY
                                                        )
                                                        let habitatBounds = CGRect(origin: .zero, size: habitatFrame.size)
                                                        if habitatBounds.contains(localPosition) {
                                                            viewModel.placeItem(dragged, at: localPosition)
                                                        }
                                                        // If dropped outside habitat & not on trash, drag is cancelled
                                                    }
                                                }
                                                
                                                // Reset drag state
                                                self.draggedItem = nil
                                                self.isDragging = false
                                                self.isOverTrash = false // Reset trash highlight
                                                self.dragOffset = .zero // Reset drag offset
                                            }
                                    )
                            }
                        }
                    }
                    .frame(maxWidth: .infinity) // Use full width within GeometryReader
                    .onAppear {
                        // Store the habitat frame in global coordinates
                        self.habitatFrame = geometry.frame(in: .global)
                    }
                    .onChange(of: geometry.frame(in: .global)) { newFrame in
                         // Update frame if layout changes
                        self.habitatFrame = newFrame
                    }
                }
                .frame(height: 300) // Give GeometryReader a defined height
                .padding(.horizontal, 16) // Consistent padding
                
                Divider()
                
                // Inventory grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        ForEach(filteredItems) { item in
                            let isPlaced = (item.type == .furniture || item.type == .decoration) && viewModel.placedItems.contains(where: { $0.id == item.id })
                            let isCurrentlyWorn = isWorn(item) // Check if the item is worn
                            let isCurrentlySelected = isSelected(item) // Check if the toy is selected

                            ItemView(item: item, showQuantity: item.isConsumable)
                                .opacity(isPlaced ? 0.5 : 1.0) // Gray out if placed
                                .overlay( // Add overlay for worn items or selected toys
                                    isCurrentlyWorn ?
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.blue, lineWidth: 3)
                                        : isCurrentlySelected ?
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.yellow, lineWidth: 3)
                                            : nil
                                )
                                .gesture(
                                    // Only allow dragging for placeable items THAT ARE NOT ALREADY PLACED
                                    (item.type == .furniture || item.type == .decoration) && !isPlaced ?
                                    DragGesture(coordinateSpace: .global) // Use global coordinate space
                                        .onChanged { value in
                                            if !isDragging {
                                                self.draggedItem = item // Set the item being dragged
                                                self.isDragging = true
                                                self.dragPosition = value.location
                                                
                                                // Calculate a small offset so the item appears under the finger
                                                // Use a consistent offset for better user experience
                                                self.dragOffset = CGPoint(x: 0, y: -30) // Position item a bit above finger
                                            } else {
                                                self.dragPosition = value.location
                                            }
                                            // Check if over trash area
                                            self.isOverTrash = trashFrame.contains(value.location)
                                        }
                                        .onEnded { value in
                                            if let dragged = self.draggedItem {
                                                if trashFrame.contains(value.location) {
                                                    // Dropped on trash (from inventory) - Just cancel, don't remove yet
                                                    // Or maybe remove immediately? Let's cancel for now.
                                                    // If we wanted to remove, we'd need a way to know it's
                                                    // not consumable and call viewModel.removeItem(dragged)
                                                    // Currently, removing directly from inventory isn't a feature.
                                                } else if habitatFrame.contains(value.location) {
                                                    // Dropped on habitat: Place item
                                                    let localPosition = CGPoint(
                                                        x: value.location.x - habitatFrame.minX,
                                                        y: value.location.y - habitatFrame.minY
                                                    )
                                                    viewModel.placeItem(dragged, at: localPosition)
                                                }
                                                // If dropped elsewhere, do nothing
                                            }
                                            // Reset drag state
                                            self.draggedItem = nil
                                            self.isDragging = false
                                            self.isOverTrash = false // Reset trash highlight
                                            self.dragOffset = .zero // Reset drag offset
                                        }
                                    : nil // No gesture for non-draggable items
                                )
                                .onTapGesture {
                                     // Handle taps separately for non-draggable items
                                    if item.type != .furniture && item.type != .decoration {
                                        handleItemTap(item)
                                    }
                                }
                        }
                    }
                    .padding()
                }
            }
            
            // Show the dragged item overlay using global position
            if let item = draggedItem, isDragging {
                 // Apply the offset to position item under the finger
                 let adjustedPosition = CGPoint(
                    x: dragPosition.x + dragOffset.x,
                    y: dragPosition.y + dragOffset.y
                 )
                
                 PlacedItemView(item: item) // Use the same view as placed items
                    .position(adjustedPosition)
                    .opacity(0.7)
                    .allowsHitTesting(false) // Prevent the overlay from blocking gestures
            }
            
            // Trash Area Overlay
            VStack {
                Spacer() // Pushes trash to the bottom
                HStack {
                    Spacer() // Pushes trash to the right
                    
                    // Only show trash when viewing furniture or decorations
                    if selectedCategory == .furniture || selectedCategory == .decoration {
                        GeometryReader { geo in
                            Image(systemName: "trash")
                                .font(.system(size: 30))
                                .foregroundColor(isOverTrash ? .red : .gray)
                                .padding(20)
                                .background(isOverTrash ? Color.red.opacity(0.2) : Color.gray.opacity(0.1))
                                .clipShape(Circle())
                                .onAppear { trashFrame = geo.frame(in: .global) }
                                .onChange(of: geo.frame(in: .global)) { trashFrame = $0 }
                        }
                        .frame(width: 80, height: 80) // Fixed frame for the trash geo reader
                        .padding(.bottom, 30)
                        .padding(.trailing, 30)
                    }
                }
            }
            .allowsHitTesting(false) // Allow gestures to pass through VStack container
            
        }
    }
    
    private func handleItemTap(_ item: Item) {
        if item.type == .hat || item.type == .accessory {
            // For wearable items, toggle wearing
            if isWorn(item) {
                viewModel.removeWornItem(item)
            } else {
                viewModel.wearItem(item)
            }
        } else if item.type == .toy {
            // For toys, toggle selection
            viewModel.selectToy(item)
        }
    }
    
    // Helper to check if a toy is selected
    private func isSelected(_ item: Item) -> Bool {
        return item.type == .toy && viewModel.isSelectedToy(item)
    }
}

// A simple view for displaying placed/dragged items consistently
struct PlacedItemView: View {
    let item: Item
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white)
                .frame(width: 60, height: 60)
                .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
            
            Image(systemName: iconFor(item))
                .font(.system(size: 30))
                .foregroundColor(colorFor(item: item))
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