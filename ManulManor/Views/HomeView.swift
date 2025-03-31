import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: ManulViewModel
    @State private var showingCertificate = false
    @State private var selectedAction: String?
    @State private var isHabitatDragging = false
    @State private var habitatOffset: CGFloat = 0
    @State private var showingFoodSelection = false
    
    // Colors for our theme
    private let primaryColor = Color(red: 0.93, green: 0.86, blue: 0.73) // Warm sand color
    private let accentColor = Color(red: 0.47, green: 0.33, blue: 0.28)  // Earth brown
    private let backgroundColor = Color(red: 0.95, green: 0.95, blue: 0.97) // Very light gray with hint of purple
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background - gradient that resembles mountain steppes
                LinearGradient(
                    gradient: Gradient(colors: [
                        backgroundColor,
                        Color(red: 0.92, green: 0.90, blue: 0.87)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(alignment: .center, spacing: 0) {
                    // Top status bar with improved layout
                    HStack {
                        // Level badge with improved visuals
                        VStack(spacing: 0) {
                            ZStack {
                                Circle()
                                    .fill(accentColor)
                                    .frame(width: 36, height: 36)
                                
                                Text("\(viewModel.manul.level)")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            
                            Text("Lv")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(accentColor)
                                .offset(y: -2)
                        }
                        .padding(.trailing, 4)
                        
                        // XP bar
                        let xpNeededForNextLevel = viewModel.manul.level * 100
                        let xpProgress = min(1.0, Double(viewModel.manul.xp) / Double(xpNeededForNextLevel))
                        
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 8)
                            
                            Capsule()
                                .fill(Color.orange.opacity(0.7))
                                .frame(width: max(0, CGFloat(xpProgress) * 80), height: 8)
                        }
                        .frame(width: 80)
                        
                        Spacer()
                        
                        // Currency with improved visuals
                        HStack(spacing: 2) {
                            Image(systemName: "dollarsign.circle.fill")
                                .font(.system(size: 18))
                                .foregroundColor(Color.yellow)
                                .shadow(color: .orange.opacity(0.3), radius: 2, x: 0, y: 1)
                            
                            Text("\(viewModel.manul.coins)")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(accentColor)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(primaryColor)
                                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                        )
                    }
                    .frame(width: geometry.size.width - 32)
                    .padding(.top, 12)
                    .padding(.bottom, 4)
                    
                    // Stats indicators with improved layout and visuals
                    HStack(spacing: 12) {
                        StatIndicator(
                            icon: "heart.fill",
                            value: viewModel.manul.happiness,
                            color: .red,
                            label: "Happiness"
                        )
                        
                        StatIndicator(
                            icon: "fork.knife",
                            value: viewModel.manul.hunger,
                            color: .orange,
                            label: "Hunger"
                        )
                        
                        StatIndicator(
                            icon: "sparkles",
                            value: viewModel.manul.hygiene,
                            color: .blue,
                            label: "Hygiene"
                        )
                    }
                    .frame(width: geometry.size.width - 32)
                    .padding(.top, 4)
                    
                    // Simple feedback message for interactions
                    if viewModel.showInteractionFeedback {
                        HStack(spacing: 12) {
                            // Icon based on interaction type
                            Image(systemName: feedbackIcon(for: viewModel.lastInteractionType))
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 32, height: 32)
                                .background(feedbackColor(for: viewModel.lastInteractionType))
                                .clipShape(Circle())
                            
                            // Message
                            Text(viewModel.interactionFeedback)
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(Color(red: 0.25, green: 0.25, blue: 0.3))
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.showInteractionFeedback)
                        .zIndex(100)
                    }
                    
                    Spacer()
                    
                    // Habitat area with manul and decorations
                    VStack(spacing: 0) {
                        RoundedRectangle(cornerRadius: 30)
                            .fill(primaryColor.opacity(0.5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(accentColor.opacity(0.2), lineWidth: 1)
                            )
                            .frame(width: geometry.size.width - 32, height: 300)
                            .overlay {
                                ZStack {
                                    // Manul view with reduced size and wearables
                                    ManulView(mood: viewModel.manul.mood, wearingItems: viewModel.manul.wearingItems, scaleFactor: 0.22)
                                        .offset(x: habitatOffset)
                                        .gesture(
                                            DragGesture()
                                                .onChanged { value in
                                                    self.isHabitatDragging = true
                                                    let horizontalDragLimit: CGFloat = 40
                                                    self.habitatOffset = min(horizontalDragLimit, max(-horizontalDragLimit, value.translation.width / 3))
                                                }
                                                .onEnded { _ in
                                                    withAnimation(.spring()) {
                                                        self.habitatOffset = 0
                                                        self.isHabitatDragging = false
                                                    }
                                                }
                                        )
                                        .scaleEffect(isHabitatDragging ? 0.95 : 1.0)
                                        .animation(.spring(response: 0.3), value: isHabitatDragging)
                                    
                                    // Placed decorations
                                    ForEach(viewModel.placedItems) { item in
                                        if let position = item.position {
                                            PlacedItemView(item: item)
                                                .position(position)
                                        }
                                    }
                                    
                                    // Animation for actions
                                    if let action = selectedAction {
                                        actionAnimation(for: action)
                                            .position(x: geometry.size.width / 2, y: geometry.size.height * 0.25) 
                                    }
                                }
                            }
                        
                        // Manul name and mood with improved visuals
                        VStack(spacing: 4) {
                            Text(viewModel.manul.name)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(accentColor)
                            
                            HStack(spacing: 6) {
                                Image(systemName: moodIcon(for: viewModel.manul.mood))
                                    .foregroundColor(moodColor(for: viewModel.manul.mood))
                                
                                Text(moodText(for: viewModel.manul.mood))
                                    .font(.system(size: 16, weight: .medium, design: .rounded))
                                    .foregroundColor(Color.gray.opacity(0.8))
                            }
                        }
                        .padding(.vertical, 12)
                    }
                    
                    Spacer()
                    
                    // Action buttons with improved layout and visuals
                    HStack(spacing: geometry.size.width * 0.06) {
                        ImprovedActionButton(
                            title: "Feed",
                            icon: "fork.knife",
                            color: .orange
                        ) {
                            showingFoodSelection = true
                        }
                        
                        ImprovedActionButton(
                            title: "Clean",
                            icon: "sparkles",
                            color: .blue
                        ) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                selectedAction = "clean"
                            }
                            
                            // Add haptic feedback
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                viewModel.cleanManul()
                                selectedAction = nil
                            }
                        }
                        
                        ImprovedActionButton(
                            title: "Play",
                            icon: "heart.fill",
                            color: .red
                        ) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                                selectedAction = "play"
                            }
                            
                            // Add haptic feedback
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                                viewModel.playWithManul()
                                selectedAction = nil
                            }
                        }
                        
                        ImprovedActionButton(
                            title: "Certificate",
                            icon: "doc.badge.fill",
                            color: .purple
                        ) {
                            // Add haptic feedback
                            let impactMed = UIImpactFeedbackGenerator(style: .medium)
                            impactMed.impactOccurred()
                            
                            showingCertificate = true
                        }
                    }
                    .frame(width: geometry.size.width - 32, alignment: .center)
                    .padding(.bottom, 25)
                }
            }
        }
        .sheet(isPresented: $showingCertificate) {
            CertificateView(certificate: viewModel.generateAdoptionCertificate())
        }
        .sheet(isPresented: $showingFoodSelection) {
            FoodSelectionView { foodItem in
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                    selectedAction = "feed"
                }
                
                // Add haptic feedback
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    viewModel.feedManul(with: foodItem)
                    selectedAction = nil
                }
            }
        }
    }
    
    // Action animations with improved visuals
    @ViewBuilder
    func actionAnimation(for action: String) -> some View {
        switch action {
        case "feed":
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.3))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "fork.knife")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)
            }
            .transition(.scale.combined(with: .opacity))
        case "clean":
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.3))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
            }
            .transition(.scale.combined(with: .opacity))
        case "play":
            // If there's a selected toy, show its icon
            if let selectedToyId = viewModel.selectedToy,
               let selectedToy = viewModel.inventory.first(where: { $0.id == selectedToyId }) {
                ZStack {
                    Circle()
                        .fill(Color.yellow.opacity(0.3))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: iconFor(selectedToy))
                        .font(.system(size: 40))
                        .foregroundColor(colorFor(item: selectedToy))
                }
                .transition(.scale.combined(with: .opacity))
            } else {
                // Default play animation if no toy is selected
                ZStack {
                    Circle()
                        .fill(Color.red.opacity(0.3))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.red)
                }
                .transition(.scale.combined(with: .opacity))
            }
        default:
            EmptyView()
        }
    }
    
    // Helper functions for mood display
    // Removed: Moved to Utilities/ViewHelpers.swift
    
    // Helper function to determine icon for placed items
    // Removed: Moved to Utilities/ViewHelpers.swift
}

// Improved certificate view
struct CertificateView: View {
    let certificate: UIImage
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Adoption Certificate")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color(red: 0.47, green: 0.33, blue: 0.28))
                .padding(.top, 30)
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
                    .padding(.horizontal, 20)
                
                Image(uiImage: certificate)
                    .resizable()
                    .scaledToFit()
                    .padding(30)
            }
            
            HStack(spacing: 20) {
                Button(action: {
                    // Share sheet implementation would go here
                    // For now just provide haptic feedback
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("Share")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .padding(.horizontal, 25)
                    .padding(.vertical, 12)
                    .background(Color(red: 0.47, green: 0.33, blue: 0.28))
                    .foregroundColor(.white)
                    .cornerRadius(25)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                }
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                        
                        Text("Close")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .padding(.horizontal, 25)
                    .padding(.vertical, 12)
                    .background(Color.gray.opacity(0.15))
                    .foregroundColor(Color(red: 0.47, green: 0.33, blue: 0.28))
                    .cornerRadius(25)
                }
            }
            .padding(.top, 10)
            
            Spacer()
        }
        .background(Color(red: 0.95, green: 0.95, blue: 0.97).ignoresSafeArea())
    }
}

// Food selection view
struct FoodSelectionView: View {
    @EnvironmentObject var viewModel: ManulViewModel
    @Environment(\.presentationMode) var presentationMode
    var onSelectFood: (Item?) -> Void
    
    var availableFoods: [Item] {
        viewModel.inventory.filter { 
            $0.type == .food && 
            $0.isPurchased && 
            $0.id != "food_grasshoppers" && // Filter out grasshoppers since we show them separately
            (viewModel.getItemQuantity($0.id) > 0 || $0.id == "food_grasshoppers") 
        }
    }
    
    var body: some View {
        NavigationView {
            List {
                // Always available grasshoppers
                Button(action: {
                    onSelectFood(nil) // Grasshoppers are the default
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "leaf.fill")
                            .foregroundColor(.green)
                            .frame(width: 30, height: 30)
                            .background(Color.green.opacity(0.2))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading) {
                            Text("Grasshoppers")
                                .font(.headline)
                            Text("Common food - always free")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Text("∞")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .padding(6)
                            .background(Circle().fill(Color.green))
                    }
                    .padding(.vertical, 8)
                }
                
                // Premium foods
                ForEach(availableFoods) { food in
                    Button(action: {
                        onSelectFood(food)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack {
                            Image(systemName: foodIcon(for: food.id))
                                .foregroundColor(foodColor(for: food.id))
                                .frame(width: 30, height: 30)
                                .background(foodColor(for: food.id).opacity(0.2))
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading) {
                                Text(food.name)
                                    .font(.headline)
                                Text(food.description)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            
                            Spacer()
                            
                            // Show quantity for consumable items
                            if food.isConsumable && food.id != "food_grasshoppers" {
                                Text("\(viewModel.getItemQuantity(food.id))")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(6)
                                    .background(Circle().fill(foodColor(for: food.id)))
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Select Food")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    func foodIcon(for foodId: String) -> String {
        switch foodId {
        case "food_grasshoppers":
            return "leaf.fill"
        case "food_pika":
            return "hare.fill"
        case "food_partridge":
            return "bird.fill"
        case "food_marmot":
            return "tortoise.fill"
        case "food_chicken":
            return "bird.fill"
        case "food_fish":
            return "fish.fill"
        default:
            return "fork.knife"
        }
    }
    
    func foodColor(for foodId: String) -> Color {
        switch foodId {
        case "food_grasshoppers":
            return .green
        case "food_pika":
            return .brown
        case "food_partridge":
            return .orange
        case "food_marmot":
            return .brown
        case "food_chicken":
            return .red
        case "food_fish":
            return .blue
        default:
            return .gray
        }
    }
} 