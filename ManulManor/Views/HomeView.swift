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
                
                VStack(spacing: 0) {
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
                    .padding(.horizontal, 16)
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
                    .padding(.horizontal, 16)
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
                    ZStack {
                        // Habitat background
                        RoundedRectangle(cornerRadius: 30)
                            .fill(primaryColor.opacity(0.5))
                            .frame(height: geometry.size.height * 0.45)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(accentColor.opacity(0.2), lineWidth: 1)
                            )
                            .padding(.horizontal, 16)
                        
                        // Manul view with improved visuals
                        ManulView(mood: viewModel.manul.mood)
                            .frame(width: 220, height: 220)
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
                        
                        // Placed decorations with improved visuals
                        ForEach(viewModel.placedItems) { item in
                            if let position = item.position {
                                // This would be the actual item image in the final version
                                ZStack {
                                    Circle()
                                        .fill(Color.yellow.opacity(0.2))
                                        .frame(width: 40, height: 40)
                                    
                                    Image(systemName: iconFor(item))
                                        .font(.system(size: 20))
                                        .foregroundColor(.yellow)
                                }
                                .position(position)
                                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 2)
                            }
                        }
                        
                        // Animation for actions
                        if let action = selectedAction {
                            actionAnimation(for: action)
                                .position(x: geometry.size.width / 2, y: geometry.size.height * 0.25)
                        }
                    }
                    .frame(height: geometry.size.height * 0.45)
                    
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
    
    // Helper functions for feedback display
    func feedbackIcon(for interactionType: String) -> String {
        switch interactionType {
        case "feed":
            return "fork.knife"
        case "clean":
            return "sparkles"
        case "play":
            return "heart.fill"
        case "purchase_success":
            return "checkmark.circle.fill"
        case "purchase_failed":
            return "xmark.circle.fill"
        case "level_up":
            return "arrow.up.circle.fill"
        case "quiz_completed":
            return "star.fill"
        default:
            return "info.circle.fill"
        }
    }
    
    func feedbackColor(for interactionType: String) -> Color {
        switch interactionType {
        case "feed":
            return .orange
        case "clean":
            return .blue
        case "play":
            return .red
        case "purchase_success", "level_up":
            return .green
        case "purchase_failed":
            return .red
        case "quiz_completed":
            return .purple
        default:
            return .gray
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
            ZStack {
                Circle()
                    .fill(Color.red.opacity(0.3))
                    .frame(width: 80, height: 80)
                
                Image(systemName: "heart.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.red)
            }
            .transition(.scale.combined(with: .opacity))
        default:
            EmptyView()
        }
    }
    
    // Helper functions for mood display
    func moodIcon(for mood: Manul.Mood) -> String {
        switch mood {
        case .happy: return "face.smiling.fill"
        case .neutral: return "face.neutral.fill"
        case .sad: return "face.sad.fill"
        case .unhappy: return "face.frowned.fill"
        }
    }
    
    func moodText(for mood: Manul.Mood) -> String {
        switch mood {
        case .happy: return "Happy"
        case .neutral: return "Content"
        case .sad: return "Sad"
        case .unhappy: return "Unhappy"
        }
    }
    
    func moodColor(for mood: Manul.Mood) -> Color {
        switch mood {
        case .happy: return .green
        case .neutral: return .orange
        case .sad: return .blue
        case .unhappy: return .gray
        }
    }
    
    // Helper function to determine icon for placed items
    func iconFor(_ item: Item) -> String {
        switch item.type {
        case .food: return "leaf.fill"
        case .toy: return "star.fill"
        case .furniture: return "bed.double.fill"
        case .decoration: return "leaf.circle.fill"
        case .hat: return "crown.fill"
        case .accessory: return "sparkles"
        }
    }
}

// Improved stat indicator with better visuals
struct StatIndicator: View {
    let icon: String
    let value: Double
    let color: Color
    let label: String
    
    var body: some View {
        VStack(spacing: 2) {
            // Icon and label
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(color)
                
                Text(label)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(Color.gray.opacity(0.8))
            }
            
            // Progress bar with improved visuals
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.gray.opacity(0.15))
                    .frame(height: 10)
                
                Capsule()
                    .fill(color.opacity(0.7))
                    .frame(width: max(5, CGFloat(self.value) * 100), height: 10)
                
                // Pill indicators for better visual feedback
                HStack(spacing: 18) {
                    ForEach(0..<5) { i in
                        Circle()
                            .fill(Color.white.opacity(0.6))
                            .frame(width: 3, height: 3)
                            .offset(x: 4 + CGFloat(i) * 18)
                    }
                }
            }
            .frame(width: 100, height: 10)
            .clipShape(Capsule())
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.8))
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        )
    }
}

// Improved action button with better visuals
struct ImprovedActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            isPressed = true
            
            // Reset after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
            
            action()
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.9))
                        .frame(width: 60, height: 60)
                        .shadow(color: color.opacity(0.3), radius: 5, x: 0, y: 3)
                    
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                }
                
                Text(title)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(Color.gray.opacity(0.8))
            }
        }
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .animation(.spring(response: 0.3), value: isPressed)
    }
}

// Improved manul view with better visuals
struct ManulView: View {
    let mood: Manul.Mood
    
    var body: some View {
        // In a real implementation, this would use actual manul images for different moods
        ZStack {
            // Body
            Circle()
                .fill(moodColor)
                .frame(width: 180, height: 180)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            // Fur texture overlay
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [moodColor.opacity(0.7), moodColor.opacity(0)]),
                        center: .center,
                        startRadius: 50,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
            
            // Ears
            HStack(spacing: 110) {
                Triangle()
                    .fill(moodColor.darker())
                    .frame(width: 45, height: 45)
                    .rotationEffect(.degrees(15))
                    .offset(x: -10, y: -65)
                
                Triangle()
                    .fill(moodColor.darker())
                    .frame(width: 45, height: 45)
                    .rotationEffect(.degrees(-15))
                    .offset(x: 10, y: -65)
            }
            
            // Face elements
            VStack(spacing: 25) {
                // Eyes
                HStack(spacing: 50) {
                    // Left eye
                    ZStack {
                        Circle() // Eye background
                            .fill(Color.white)
                            .frame(width: 30, height: 30)
                        
                        Circle() // Pupil
                            .fill(Color.black)
                            .frame(width: eyeSize, height: eyeSize)
                            .offset(pupilOffset)
                    }
                    
                    // Right eye
                    ZStack {
                        Circle() // Eye background
                            .fill(Color.white)
                            .frame(width: 30, height: 30)
                        
                        Circle() // Pupil
                            .fill(Color.black)
                            .frame(width: eyeSize, height: eyeSize)
                            .offset(pupilOffset)
                    }
                }
                
                // Nose
                Triangle()
                    .fill(Color.pink.opacity(0.8))
                    .frame(width: 18, height: 12)
                    .rotationEffect(.degrees(180))
                
                // Mouth
                moodExpression
                    .foregroundColor(Color.black.opacity(0.6))
                    .offset(y: -10)
            }
            
            // Whiskers
            HStack(spacing: 65) {
                // Left whiskers
                VStack(spacing: 6) {
                    ForEach(0..<3) { i in
                        Rectangle()
                            .fill(Color.white.opacity(0.6))
                            .frame(width: 25, height: 1.5)
                            .rotationEffect(.degrees(Double(i) * 5 - 5))
                    }
                }
                .offset(x: -30, y: 0)
                
                // Right whiskers
                VStack(spacing: 6) {
                    ForEach(0..<3) { i in
                        Rectangle()
                            .fill(Color.white.opacity(0.6))
                            .frame(width: 25, height: 1.5)
                            .rotationEffect(.degrees(Double(i) * -5 + 5))
                    }
                }
                .offset(x: 30, y: 0)
            }
        }
    }
    
    // Helper computed properties for eyes
    private var eyeSize: CGFloat {
        switch mood {
        case .happy: return 18
        case .neutral: return 18
        case .sad: return 16
        case .unhappy: return 14
        }
    }
    
    private var pupilOffset: CGSize {
        switch mood {
        case .happy: return CGSize(width: 0, height: 0)
        case .neutral: return CGSize(width: 0, height: 0)
        case .sad: return CGSize(width: 0, height: 3)
        case .unhappy: return CGSize(width: 0, height: 5)
        }
    }
    
    var moodColor: Color {
        switch mood {
        case .happy:
            return Color(red: 0.85, green: 0.75, blue: 0.63) // Light tan
        case .neutral:
            return Color(red: 0.82, green: 0.73, blue: 0.61) // Slightly darker tan
        case .sad:
            return Color(red: 0.78, green: 0.70, blue: 0.58) // Grayish tan
        case .unhappy:
            return Color(red: 0.75, green: 0.68, blue: 0.58) // More gray
        }
    }
    
    @ViewBuilder
    var moodExpression: some View {
        switch mood {
        case .happy:
            Path { path in
                path.move(to: CGPoint(x: -20, y: 0))
                path.addQuadCurve(to: CGPoint(x: 20, y: 0), control: CGPoint(x: 0, y: -15))
            }
            .stroke(Color.black, lineWidth: 2)
        case .neutral:
            Rectangle()
                .frame(width: 25, height: 2)
        case .sad:
            Path { path in
                path.move(to: CGPoint(x: -20, y: 0))
                path.addQuadCurve(to: CGPoint(x: 20, y: 0), control: CGPoint(x: 0, y: 15))
            }
            .stroke(Color.black, lineWidth: 2)
        case .unhappy:
            Path { path in
                path.move(to: CGPoint(x: -25, y: 0))
                path.addQuadCurve(to: CGPoint(x: 25, y: 0), control: CGPoint(x: 0, y: 25))
            }
            .stroke(Color.black, lineWidth: 2)
        }
    }
}

// Custom triangle shape for ears
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// Extension for color manipulation
extension Color {
    func darker(by percentage: CGFloat = 0.2) -> Color {
        return self.opacity(1 - percentage)
    }
    
    func lighter(by percentage: CGFloat = 0.2) -> Color {
        return self.opacity(1 + percentage)
    }
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
        viewModel.inventory.filter { $0.type == .food && $0.isPurchased && (viewModel.getItemQuantity($0.id) > 0 || $0.id == "food_grasshoppers") }
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