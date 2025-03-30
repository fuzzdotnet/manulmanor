import SwiftUI

struct ContentView: View {
    @EnvironmentObject var manulViewModel: ManulViewModel
    @State private var selectedTab: Tab = .home
    
    // Theme colors
    private let primaryColor = Color(red: 0.93, green: 0.86, blue: 0.73) // Warm sand color
    private let accentColor = Color(red: 0.47, green: 0.33, blue: 0.28)  // Earth brown
    private let backgroundColor = Color(red: 0.95, green: 0.95, blue: 0.97) // Very light gray with hint of purple
    
    enum Tab {
        case home, inventory, quiz, shop, settings
    }
    
    var body: some View {
        ZStack {
            if manulViewModel.isOnboarding {
                // Show onboarding
                OnboardingView()
            } else {
                // Main content
                VStack(spacing: 0) {
                    // Tab content
                    ZStack {
                        switch selectedTab {
                        case .home:
                            HomeView()
                        case .inventory:
                            InventoryView()
                        case .quiz:
                            QuizView()
                        case .shop:
                            ShopView()
                        case .settings:
                            SettingsView()
                        }
                    }
                    
                    // Custom Tab Bar
                    CustomTabBar(selectedTab: $selectedTab)
                }
                .ignoresSafeArea(edges: .bottom)
            }
        }
        .onAppear {
            // Check for Monday quiz
            manulViewModel.checkForWeeklyQuiz()
            
            // Apply custom appearance
            setupAppearance()
        }
    }
    
    private func setupAppearance() {
        // Set up UIKit appearance for consistent styling
        UINavigationBar.appearance().largeTitleTextAttributes = [
            .foregroundColor: UIColor(accentColor)
        ]
        
        UINavigationBar.appearance().titleTextAttributes = [
            .foregroundColor: UIColor(accentColor)
        ]
        
        UITabBar.appearance().isHidden = true
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: ContentView.Tab
    @State private var lastSelectedTab: ContentView.Tab = .home
    @Namespace private var animation
    
    // Colors
    private let tabBackground = Color(red: 0.93, green: 0.86, blue: 0.73)
    private let activeColor = Color(red: 0.47, green: 0.33, blue: 0.28)
    private let inactiveColor = Color.gray.opacity(0.6)
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { index in
                let tab = tabs[index]
                TabButton(tab: tab, animation: animation, selectedTab: $selectedTab, lastSelectedTab: $lastSelectedTab)
                
                if index < tabs.count - 1 {
                    Spacer(minLength: 0)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 15)
        .padding(.bottom, 30) // Extra padding for bottom safe area
        .background(
            tabBackground
                .clipShape(
                    CustomShape()
                )
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: -5)
        )
    }
    
    private var tabs: [(icon: String, title: String, tab: ContentView.Tab)] {
        [
            ("house.fill", "Home", .home),
            ("square.grid.2x2.fill", "Items", .inventory),
            ("questionmark.circle.fill", "Quiz", .quiz),
            ("bag.fill", "Shop", .shop),
            ("gearshape.fill", "Settings", .settings)
        ]
    }
}

struct TabButton: View {
    let tab: (icon: String, title: String, tab: ContentView.Tab)
    let animation: Namespace.ID
    
    @Binding var selectedTab: ContentView.Tab
    @Binding var lastSelectedTab: ContentView.Tab
    @State private var tabScale: CGFloat = 1.0
    
    // Colors
    private let activeColor = Color(red: 0.47, green: 0.33, blue: 0.28)
    private let inactiveColor = Color.gray.opacity(0.6)
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                lastSelectedTab = selectedTab
                selectedTab = tab.tab
            }
            
            // Add haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            
            // Add scale animation
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                tabScale = 0.8
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    tabScale = 1.0
                }
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: tab.icon)
                    .font(.system(size: 22))
                    .foregroundColor(selectedTab == tab.tab ? activeColor : inactiveColor)
                    .frame(height: 22)
                
                Text(tab.title)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(selectedTab == tab.tab ? activeColor : inactiveColor)
                
                // Indicator for selected tab
                if selectedTab == tab.tab {
                    Circle()
                        .fill(activeColor)
                        .frame(width: 5, height: 5)
                        .matchedGeometryEffect(id: "TAB_INDICATOR", in: animation)
                        .offset(y: 1)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 5, height: 5)
                }
            }
            .scaleEffect(tabScale)
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
    }
}

// Custom shape for tab bar with curved top
struct CustomShape: Shape {
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath()
        
        // Starting point (bottom left)
        path.move(to: CGPoint(x: 0, y: 0))
        
        // Bottom edge
        path.addLine(to: CGPoint(x: rect.width, y: 0))
        
        // Right edge
        path.addLine(to: CGPoint(x: rect.width, y: rect.height))
        
        // Top curved edge
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        
        // Left edge
        path.close()
        
        return Path(path.cgPath)
    }
} 