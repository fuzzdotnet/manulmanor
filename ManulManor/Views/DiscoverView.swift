import SwiftUI

struct DiscoverView: View {
    @EnvironmentObject var viewModel: ManulViewModel
    @State private var selectedSection: DiscoverSection = .quiz
    @State private var showingConservationGoals = false
    @State private var showingPartnerOrganizations = false
    @State private var showingYourImpact = false
    
    enum DiscoverSection {
        case quiz, conservation, impact
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                Text("Discover")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                    .padding(.bottom, 8)
                
                // Manul Monday Quiz Section
                VStack(spacing: 10) {
                    Text("Manul Monday Quiz")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Quiz card
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.orange.opacity(0.15))
                            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                            
                        if let quiz = viewModel.currentQuiz {
                            if quiz.isCompleted {
                                QuizSummaryCard(quiz: quiz)
                            } else {
                                QuizPromptCard()
                                    .onTapGesture {
                                        selectedSection = .quiz
                                    }
                            }
                        } else {
                            NoQuizCard()
                        }
                    }
                    .frame(height: 180)
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
                
                // Conservation section
                VStack(spacing: 10) {
                    Text("Conservation")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Conservation cards
                    VStack(spacing: 16) {
                        // Conservation goals card
                        ConservationCard(
                            title: "Our Conservation Goals",
                            description: "Learn about our mission to protect Pallas cats in the wild",
                            icon: "shield.lefthalf.filled",
                            color: .blue
                        )
                        .onTapGesture {
                            showingConservationGoals = true
                        }
                        
                        // Partner organizations card
                        ConservationCard(
                            title: "Partner Organizations",
                            description: "Meet the organizations we support through your play",
                            icon: "building.2.fill",
                            color: .green
                        )
                        .onTapGesture {
                            showingPartnerOrganizations = true
                        }
                        
                        // Impact card
                        ConservationCard(
                            title: "Your Impact",
                            description: "See how your contributions help conservation efforts",
                            icon: "heart.fill",
                            color: .red
                        )
                        .onTapGesture {
                            showingYourImpact = true
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
                
                // Did you know section
                VStack(spacing: 10) {
                    Text("Did You Know?")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Fun fact card
                    ZStack {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.purple.opacity(0.15))
                            .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                        
                        HStack(alignment: .top, spacing: 16) {
                            Image(systemName: "lightbulb.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.yellow)
                                .padding(.top, 4)
                            
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Pallas cats have round pupils!")
                                    .font(.headline)
                                
                                Text("Unlike other small felines that have vertical slit pupils, Pallas cats have round pupils - one of their most distinctive features that helps them hunt in bright, open environments.")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 6)
                            
                            Spacer()
                        }
                        .padding()
                    }
                    .frame(height: 140)
                    .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
            .padding(.bottom, 30) // Additional bottom padding for the tab bar
        }
        .background(Color(red: 0.96, green: 0.96, blue: 0.98).ignoresSafeArea())
        .sheet(isPresented: Binding<Bool>(
            get: { selectedSection == .quiz && viewModel.currentQuiz != nil && !viewModel.currentQuiz!.isCompleted },
            set: { if !$0 { selectedSection = .conservation } }
        )) {
            if let quiz = viewModel.currentQuiz, !quiz.isCompleted {
                QuizView()
                    .environmentObject(viewModel)
            }
        }
        .sheet(isPresented: $showingConservationGoals) {
            ConservationGoalsView()
        }
        .sheet(isPresented: $showingPartnerOrganizations) {
            PartnerOrganizationsView()
        }
        .sheet(isPresented: $showingYourImpact) {
            YourImpactView()
        }
    }
}

// Quiz summary card for completed quizzes
struct QuizSummaryCard: View {
    let quiz: Quiz
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 26))
                .foregroundColor(.green)
                .padding(.bottom, 4)
            
            Text("This week's quiz completed!")
                .font(.headline)
                .fontWeight(.bold)
            
            Text("Score: \(quiz.score)/\(quiz.maxScore)")
                .font(.subheadline)
                .foregroundColor(.primary)
            
            Text("Come back next Monday for a new quiz")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// Quiz prompt card for available but uncompleted quizzes
struct QuizPromptCard: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "doc.text.fill")
                .font(.system(size: 26))
                .foregroundColor(.blue)
                .padding(.bottom, 4)
            
            Text("This week's quiz is available!")
                .font(.headline)
                .fontWeight(.bold)
            
            Text("Test your knowledge about Pallas cats")
                .font(.subheadline)
            
            Text("Tap to start")
                .font(.caption)
                .foregroundColor(.blue)
                .padding(.vertical, 6)
                .padding(.horizontal, 16)
                .background(Capsule().fill(Color.blue.opacity(0.1)))
        }
        .padding()
    }
}

// No quiz card for when there's no active quiz
struct NoQuizCard: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "calendar")
                .font(.system(size: 26))
                .foregroundColor(.gray)
                .padding(.bottom, 4)
            
            Text("No quiz available right now")
                .font(.headline)
                .fontWeight(.bold)
            
            Text("Come back on Monday for a new quiz")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// Conservation card component
struct ConservationCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }
            
            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14, weight: .bold))
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        )
    }
} 