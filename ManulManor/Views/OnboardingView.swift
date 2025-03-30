import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject var viewModel: ManulViewModel
    @State private var currentPage = 0
    @State private var manulName = ""
    @State private var isNameValid = false
    
    // Onboarding pages content
    let pages = [
        OnboardingPage(
            image: "globe",
            title: "Welcome to Manul Manor!",
            description: "Meet and care for your own Pallas cat, one of the world's most fascinating and endangered feline species."
        ),
        OnboardingPage(
            image: "heart.fill",
            title: "Take care of your manul",
            description: "Feed, clean, and play with your Pallas cat to keep it happy. Watch as your bond grows stronger daily!"
        ),
        OnboardingPage(
            image: "house.fill",
            title: "Decorate your manor",
            description: "Create the perfect home for your manul with furniture, toys, and decorations. Make it cozy and comfortable."
        ),
        OnboardingPage(
            image: "brain.head.profile",
            title: "Learn & Protect",
            description: "Take weekly quizzes about these incredible cats and learn how your play helps support real-world conservation efforts."
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [Color.orange.opacity(0.2), Color.brown.opacity(0.2)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Main content
            VStack {
                if currentPage < pages.count {
                    // Page indicator
                    HStack(spacing: 8) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index ? Color.blue : Color.gray.opacity(0.5))
                                .frame(width: 8, height: 8)
                        }
                    }
                    .padding(.top, 20)
                    
                    // Page content
                    VStack(spacing: 30) {
                        Image(systemName: pages[currentPage].image)
                            .font(.system(size: 100))
                            .foregroundColor(.orange)
                            .padding()
                        
                        Text(pages[currentPage].title)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(pages[currentPage].description)
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 30)
                    }
                    .padding(.vertical, 50)
                    
                    // Navigation buttons
                    HStack(spacing: 40) {
                        Button("Skip") {
                            // Skip to name selection
                            currentPage = pages.count
                        }
                        .font(.headline)
                        .foregroundColor(.gray)
                        
                        Button(currentPage < pages.count - 1 ? "Next" : "Continue") {
                            withAnimation {
                                currentPage += 1
                            }
                        }
                        .font(.headline)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                    .padding(.bottom, 30)
                    
                } else {
                    // Name selection view
                    VStack(spacing: 30) {
                        Image(systemName: "pawprint.circle.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.orange)
                            .padding()
                        
                        Text("Name Your Manul")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Every Pallas cat needs a name. What will you call yours?")
                            .font(.body)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        // Name input field
                        VStack(alignment: .leading, spacing: 5) {
                            TextField("Enter a name", text: $manulName)
                                .font(.title3)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .onChange(of: manulName) { newValue in
                                    isNameValid = !newValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                }
                            
                            if !isNameValid && !manulName.isEmpty {
                                Text("Please enter a valid name.")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .padding(.leading)
                            }
                        }
                        .padding(.horizontal, 30)
                        
                        Spacer()
                        
                        // Start button
                        Button("Start Your Journey") {
                            if isNameValid {
                                completeOnboarding()
                            }
                        }
                        .font(.headline)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 15)
                        .background(isNameValid ? Color.blue : Color.gray)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.bottom, 50)
                        .disabled(!isNameValid)
                    }
                    .padding()
                }
            }
        }
    }
    
    private func completeOnboarding() {
        viewModel.completeOnboarding(withManulName: manulName)
    }
}

// Helper struct for onboarding pages
struct OnboardingPage {
    let image: String // SF Symbol name
    let title: String
    let description: String
}

// Preview
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(ManulViewModel())
    }
} 