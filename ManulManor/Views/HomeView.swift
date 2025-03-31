import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: ManulViewModel
    @State private var showingCertificate = false
    @State private var selectedAction: String?
    @State private var isHabitatDragging = false
    @State private var habitatOffset: CGFloat = 0
    @State private var showingFoodSelection = false
    @State private var isStatsExpanded = false
    
    // Colors for our theme
    private let primaryColor = Color(red: 0.93, green: 0.86, blue: 0.73) // Warm sand color
    private let accentColor = Color(red: 0.47, green: 0.33, blue: 0.28)  // Earth brown
    private let backgroundColor = Color(red: 0.75, green: 0.8, blue: 0.55) // Steppe green background
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Full-screen nature background that resembles a forest clearing
                backgroundColor
                    .ignoresSafeArea()
                
                // Ground details
                VStack {
                    Spacer()
                    
                    // Ground curve
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: geometry.size.height * 0.25))
                        path.addQuadCurve(
                            to: CGPoint(x: geometry.size.width, y: geometry.size.height * 0.25),
                            control: CGPoint(x: geometry.size.width/2, y: geometry.size.height * 0.35)
                        )
                        path.addLine(to: CGPoint(x: geometry.size.width, y: geometry.size.height))
                        path.addLine(to: CGPoint(x: 0, y: geometry.size.height))
                        path.closeSubpath()
                    }
                    .fill(Color(red: 0.62, green: 0.73, blue: 0.40))
                }
                .ignoresSafeArea()
                
                // Main content overlay
                VStack(alignment: .center, spacing: 0) {
                    // Top status indicators as a horizontal bar
                    HStack(spacing: 0) {
                        // Level badge with XP
                        HStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(accentColor)
                                    .frame(width: 36, height: 36)
                                
                                Text("\(viewModel.manul.level)")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            
                            // Simple XP bar
                            let xpNeededForNextLevel = viewModel.manul.level * 100
                            let xpProgress = min(1.0, Double(viewModel.manul.xp) / Double(xpNeededForNextLevel))
                            
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.black.opacity(0.15))
                                    .frame(width: 60, height: 6)
                                
                                Capsule()
                                    .fill(Color.white.opacity(0.9))
                                    .frame(width: max(0, CGFloat(xpProgress) * 60), height: 6)
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(Capsule().fill(Color.white.opacity(0.3)))
                        
                        Spacer()
                        
                        // Expandable stats trigger in the center top
                        Button(action: {
                            withAnimation(.spring()) {
                                isStatsExpanded.toggle()
                            }
                        }) {
                            Image(systemName: isStatsExpanded ? "chevron.up" : "chevron.down")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Circle().fill(Color.black.opacity(0.3)))
                        }
                        .padding(.horizontal, 10)
                        
                        Spacer()
                        
                        // Coins currency - now matching level indicator's style
                        HStack(spacing: 6) {
                            ZStack {
                                Circle()
                                    .fill(Color.yellow.opacity(0.8))
                                    .frame(width: 36, height: 36)
                                
                                Image(systemName: "dollarsign.circle")
                                    .foregroundColor(.white)
                                    .font(.system(size: 18, weight: .bold))
                            }
                            
                            Text("\(viewModel.manul.coins)")
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(Capsule().fill(Color.white.opacity(0.3)))
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 12)
                    
                    // Fixed-size stats container area
                    ZStack(alignment: .top) {
                        // Transparent placeholder to reserve space
                        Color.clear
                            .frame(height: isStatsExpanded ? 100 : 10)
                        
                        // Stats panel - now appears in overlay without pushing content
                        if isStatsExpanded {
                            // Stats indicators with improved layout and visuals
                            HStack(spacing: 12) {
                                // Happiness stat
                                StatCard(
                                    icon: "heart.fill",
                                    iconColor: .red,
                                    label: "Happiness",
                                    value: viewModel.manul.happiness,
                                    color: .red
                                )
                                
                                // Hunger stat
                                StatCard(
                                    icon: "fork.knife",
                                    iconColor: .orange,
                                    label: "Hunger",
                                    value: viewModel.manul.hunger,
                                    color: .orange
                                )
                                
                                // Hygiene stat
                                StatCard(
                                    icon: "sparkles",
                                    iconColor: .blue,
                                    label: "Hygiene",
                                    value: viewModel.manul.hygiene,
                                    color: .blue
                                )
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    
                    // Stats visual separator - subtle curved background
                    if isStatsExpanded {
                        Path { path in
                            path.move(to: CGPoint(x: 0, y: 0))
                            path.addQuadCurve(
                                to: CGPoint(x: geometry.size.width, y: 0),
                                control: CGPoint(x: geometry.size.width/2, y: 30)
                            )
                            path.addLine(to: CGPoint(x: geometry.size.width, y: 60))
                            path.addLine(to: CGPoint(x: 0, y: 60))
                            path.closeSubpath()
                        }
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 60)
                        .offset(y: -40)
                    }
                    
                    // Feedback message toast
                    if viewModel.showInteractionFeedback {
                        FeedbackToast(
                            message: viewModel.interactionFeedback,
                            interactionType: viewModel.lastInteractionType
                        )
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.showInteractionFeedback)
                        .zIndex(100)
                    }
                    
                    Spacer()
                    
                    // The central habitat area now fills most of the screen
                    ZStack {
                        // Circular area for the manul's habitat
                        Circle()
                            .fill(Color(red: 0.82, green: 0.78, blue: 0.67)) // Sandy steppe ground
                            .frame(width: min(geometry.size.width * 0.8, 300))
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                            .overlay(
                                // Ground texture overlay
                                Circle()
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                                    .background(
                                        Circle()
                                            .fill(
                                                RadialGradient(
                                                    gradient: Gradient(colors: [
                                                        Color(red: 0.85, green: 0.82, blue: 0.7),
                                                        Color(red: 0.78, green: 0.75, blue: 0.62)
                                                    ]),
                                                    center: .center,
                                                    startRadius: 0,
                                                    endRadius: 150
                                                )
                                            )
                                    )
                                    .clipShape(Circle())
                            )
                        
                        // Rock formation placeholder
                        ZStack {
                            // Base of the rock formation
                            Path { path in
                                // Main rock
                                path.move(to: CGPoint(x: -50, y: 20))
                                path.addQuadCurve(
                                    to: CGPoint(x: -10, y: -40),
                                    control: CGPoint(x: -40, y: -30)
                                )
                                path.addQuadCurve(
                                    to: CGPoint(x: 30, y: -20),
                                    control: CGPoint(x: 20, y: -50)
                                )
                                path.addQuadCurve(
                                    to: CGPoint(x: 50, y: 10),
                                    control: CGPoint(x: 50, y: -10)
                                )
                                path.addQuadCurve(
                                    to: CGPoint(x: 20, y: 30),
                                    control: CGPoint(x: 45, y: 30)
                                )
                                path.addQuadCurve(
                                    to: CGPoint(x: -50, y: 20),
                                    control: CGPoint(x: -10, y: 50)
                                )
                            }
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(red: 0.6, green: 0.55, blue: 0.5),
                                        Color(red: 0.5, green: 0.45, blue: 0.4)
                                    ]),
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            
                            // Small rocks around the main formation
                            Circle()
                                .fill(Color(red: 0.55, green: 0.5, blue: 0.45))
                                .frame(width: 25, height: 18)
                                .offset(x: -60, y: 10)
                            
                            Ellipse()
                                .fill(Color(red: 0.6, green: 0.55, blue: 0.5))
                                .frame(width: 35, height: 20)
                                .offset(x: 60, y: 15)
                                .rotationEffect(.degrees(15))
                            
                            // Rock texture/details
                            Path { path in
                                path.move(to: CGPoint(x: -20, y: -20))
                                path.addLine(to: CGPoint(x: 0, y: -15))
                                path.addLine(to: CGPoint(x: -10, y: -5))
                            }
                            .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            
                            Path { path in
                                path.move(to: CGPoint(x: 10, y: 0))
                                path.addLine(to: CGPoint(x: 30, y: 10))
                            }
                            .stroke(Color.gray.opacity(0.4), lineWidth: 1)
                            
                            // Text to indicate this is a placeholder
                            // Remove this in final version when real SVG is used
                            Text("Rock Formation\nPlaceholder")
                                .font(.system(size: 8))
                                .foregroundColor(.white.opacity(0.6))
                                .multilineTextAlignment(.center)
                                .offset(y: -5)
                        }
                        .frame(width: 150, height: 100)
                        .offset(y: 30)
                        
                        // Manul character
                        ManulView(mood: viewModel.manul.mood, wearingItems: viewModel.manul.wearingItems, scaleFactor: 0.3)
                            .offset(x: habitatOffset, y: -15)
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
                        
                        // Action animations
                        if let action = selectedAction {
                            actionAnimation(for: action)
                                .offset(y: -50)
                        }
                        
                        // Add some sparse grass tufts around the edges
                        ForEach(0..<8) { i in
                            let angle = Double(i) * .pi / 4
                            let radius = 130.0
                            let x = cos(angle) * radius
                            let y = sin(angle) * radius
                            
                            GrassTuft()
                                .offset(x: CGFloat(x), y: CGFloat(y))
                                .rotationEffect(.degrees(Double(i * 45)))
                        }
                    }
                    .frame(maxHeight: .infinity)
                    
                    // Bottom action area
                    VStack(spacing: 8) {
                        // Manul name and mood
                        HStack(spacing: 6) {
                            Image(systemName: moodIcon(for: viewModel.manul.mood))
                                .foregroundColor(moodColor(for: viewModel.manul.mood))
                            
                            Text(viewModel.manul.name)
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Text("• \(moodText(for: viewModel.manul.mood))")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.vertical, 8)
                        
                        // Minimalistic action buttons
                        HStack(spacing: geometry.size.width * 0.08) {
                            CircleActionButton(
                                icon: "fork.knife",
                                color: .orange
                            ) {
                                showingFoodSelection = true
                            }
                            
                            CircleActionButton(
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
                            
                            CircleActionButton(
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
                            
                            // Add certificate button here
                            CircleActionButton(
                                icon: "doc.badge.fill",
                                color: .purple
                            ) {
                                showingCertificate = true
                            }
                        }
                        .padding(.bottom, 16)
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .sheet(isPresented: $showingFoodSelection) {
            FoodSelectionView(onSelectFood: { foodItem in
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
            })
        }
        .sheet(isPresented: $showingCertificate) {
            CertificateView(certificate: viewModel.generateAdoptionCertificate())
        }
    }
    
    // Helper for feeding action
    private func feedManul() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
            selectedAction = "feed"
        }
        
        // Add haptic feedback
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        impactMed.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            viewModel.feedManul()
            selectedAction = nil
        }
    }
    
    // Helper functions for mood indicators
    private func moodIcon(for mood: Manul.Mood) -> String {
        switch mood {
        case .happy: return "face.smiling"
        case .neutral: return "face.neutral"
        case .sad: return "face.concerned"
        case .unhappy: return "face.sad"
        }
    }
    
    private func moodColor(for mood: Manul.Mood) -> Color {
        switch mood {
        case .happy: return .green
        case .neutral: return .yellow
        case .sad: return .orange
        case .unhappy: return .red
        }
    }
    
    private func moodText(for mood: Manul.Mood) -> String {
        switch mood {
        case .happy: return "Happy"
        case .neutral: return "Content"
        case .sad: return "Sad"
        case .unhappy: return "Unhappy"
        }
    }
    
    // Animation helper
    private func actionAnimation(for action: String) -> some View {
        Group {
            switch action {
            case "feed":
                Image(systemName: "fork.knife")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
                    .opacity(0.8)
                    .scaleEffect(1.2)
                    .rotationEffect(.degrees(15))
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: selectedAction)
            case "clean":
                Image(systemName: "sparkles")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                    .opacity(0.8)
                    .scaleEffect(1.2)
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: selectedAction)
            case "play":
                // Check if a toy is equipped
                if let selectedToyId = viewModel.selectedToy,
                   let selectedToy = viewModel.inventory.first(where: { $0.id == selectedToyId }) {
                    // Show the specific toy
                    ZStack {
                        Circle()
                            .fill(Color.yellow.opacity(0.3))
                            .frame(width: 80, height: 80)
                        
                        Image(systemName: iconFor(selectedToy))
                            .font(.system(size: 40))
                            .foregroundColor(colorFor(item: selectedToy))
                    }
                    .scaleEffect(1.2)
                    .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: selectedAction)
                } else {
                    // Default heart animation if no toy is selected
                    Image(systemName: "heart.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.red)
                        .opacity(0.8)
                        .scaleEffect(1.2)
                        .animation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: selectedAction)
                }
            default:
                EmptyView()
            }
        }
    }
    
    // Helper for feedback icons
    private func feedbackIcon(for interactionType: String) -> String {
        switch interactionType {
        case "feed": return "fork.knife"
        case "clean": return "sparkles"
        case "play": return "heart.fill"
        case "purchase_success": return "cart.fill.badge.plus"
        case "place_item", "remove_item": return "chair.fill"
        default: return "info.circle"
        }
    }
    
    // Helper for feedback colors
    private func feedbackColor(for interactionType: String) -> Color {
        switch interactionType {
        case "feed": return .orange
        case "clean": return .blue
        case "play": return .red
        case "purchase_success": return .green
        case "place_item", "remove_item": return .purple
        default: return .gray
        }
    }
    
    // Add missing helper functions
    private func iconFor(_ item: Item) -> String {
        switch item.type {
        case .food: return "fork.knife"
        case .toy: return "star.fill" 
        case .furniture: return "bed.double.fill"
        case .decoration: return "leaf.fill"
        case .hat: return "crown.fill"
        case .accessory: return "gift.fill"
        }
    }
    
    private func colorFor(item: Item) -> Color {
        switch item.type {
        case .food:
            return .orange
        case .toy:
            return .yellow
        case .furniture:
            return .brown
        case .decoration:
            return Color(red: 0.2, green: 0.8, blue: 0.3)
        case .hat:
            return .purple
        case .accessory:
            return .pink
        }
    }
}

// Cleaner stat card design for the expandable stats display
struct StatCard: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Label and icon
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 14))
                
                Text(label)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
            }
            
            // Progress bar
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.3))
                    .frame(height: 8)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(color)
                    .frame(width: max(5, CGFloat(value) * 100), height: 8)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.2))
        )
    }
}

// New compact resource indicator
struct ResourceIndicator: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 12, weight: .bold))
            
            Text(value)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundColor(.white)
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(Capsule().fill(Color.black.opacity(0.2)))
    }
}

// Circle action button for minimalist design
struct CircleActionButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.9))
                    .frame(width: 60, height: 60)
                    .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 2)
                
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }
        }
    }
}

// Expandable view component
struct ExpandableView<Content: View>: View {
    @State private var isExpanded = false
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Pull tab
            Button(action: {
                withAnimation(.spring()) {
                    isExpanded.toggle()
                }
            }) {
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Capsule().fill(Color.black.opacity(0.3)))
                    .padding(.top, 4)
            }
            
            if isExpanded {
                content
                    .padding(.top, 8)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}

// Feedback toast component
struct FeedbackToast: View {
    let message: String
    let interactionType: String
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon based on interaction type
            Image(systemName: feedbackIcon(for: interactionType))
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(feedbackColor(for: interactionType))
                .clipShape(Circle())
            
            // Message
            Text(message)
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
    }
    
    // Helper for feedback icons
    private func feedbackIcon(for interactionType: String) -> String {
        switch interactionType {
        case "feed": return "fork.knife"
        case "clean": return "sparkles"
        case "play": return "heart.fill"
        case "purchase_success": return "cart.fill.badge.plus"
        case "place_item", "remove_item": return "chair.fill"
        default: return "info.circle"
        }
    }
    
    // Helper for feedback colors
    private func feedbackColor(for interactionType: String) -> Color {
        switch interactionType {
        case "feed": return .orange
        case "clean": return .blue
        case "play": return .red
        case "purchase_success": return .green
        case "place_item", "remove_item": return .purple
        default: return .gray
        }
    }
}

// Previous ImprovedActionButton is no longer needed with new design

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

// Add a new component for grass tufts
struct GrassTuft: View {
    var body: some View {
        ZStack {
            // Multiple blades of grass
            ForEach(0..<3) { i in
                Path { path in
                    path.move(to: CGPoint(x: CGFloat(i) * 3 - 3, y: 0))
                    path.addQuadCurve(
                        to: CGPoint(x: CGFloat(i) * 3 - 6, y: -10 - CGFloat(i) * 3),
                        control: CGPoint(x: CGFloat(i) * 3 - 7, y: -5)
                    )
                }
                .stroke(
                    Color(red: 0.5, green: 0.65, blue: 0.3),
                    style: StrokeStyle(lineWidth: 1.5, lineCap: .round)
                )
            }
        }
        .frame(width: 10, height: 15)
    }
} 