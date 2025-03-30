import SwiftUI

struct QuizView: View {
    @EnvironmentObject var viewModel: ManulViewModel
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswerIndex: Int? = nil
    @State private var isAnswerCorrect: Bool? = nil
    @State private var showingExplanation = false
    @State private var quizCompleted = false
    
    var body: some View {
        VStack {
            // Header
            Text("Manul Monday Quiz")
                .font(.title)
                .fontWeight(.bold)
                .padding()
            
            if let quiz = viewModel.currentQuiz {
                if quiz.isCompleted {
                    completedQuizView(quiz)
                } else {
                    activeQuizView(quiz)
                }
            } else {
                noQuizView()
            }
        }
        .background(Color.orange.opacity(0.1).ignoresSafeArea())
    }
    
    @ViewBuilder
    func activeQuizView(_ quiz: Quiz) -> some View {
        VStack(spacing: 20) {
            // Progress indicator
            HStack {
                ForEach(0..<quiz.questions.count, id: \.self) { index in
                    Circle()
                        .fill(index == currentQuestionIndex ? Color.blue : Color.gray.opacity(0.5))
                        .frame(width: 10, height: 10)
                }
            }
            .padding()
            
            // Question
            let question = quiz.questions[currentQuestionIndex]
            
            Text("Question \(currentQuestionIndex + 1) of \(quiz.questions.count)")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text(question.question)
                .font(.title3)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding()
                .frame(maxWidth: .infinity)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                .padding(.horizontal)
            
            // Answer options
            VStack(spacing: 12) {
                ForEach(0..<question.options.count, id: \.self) { index in
                    Button(action: {
                        if selectedAnswerIndex == nil {
                            selectedAnswerIndex = index
                            isAnswerCorrect = viewModel.submitQuizAnswer(
                                questionIndex: currentQuestionIndex,
                                answerIndex: index
                            )
                            
                            // Show explanation
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showingExplanation = true
                            }
                        }
                    }) {
                        HStack {
                            Text(question.options[index])
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .background(backgroundColor(for: index))
                        .foregroundColor(selectedAnswerIndex == index ? .white : .primary)
                        .cornerRadius(10)
                    }
                    .disabled(selectedAnswerIndex != nil)
                }
            }
            .padding()
            
            Spacer()
            
            // Explanation panel (appears after answer is selected)
            if showingExplanation {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: isAnswerCorrect ?? false ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundColor(isAnswerCorrect ?? false ? .green : .red)
                            .font(.title2)
                        
                        Text(isAnswerCorrect ?? false ? "Correct!" : "Incorrect")
                            .font(.headline)
                            .foregroundColor(isAnswerCorrect ?? false ? .green : .red)
                        
                        Spacer()
                    }
                    
                    Text("Explanation:")
                        .font(.subheadline)
                        .fontWeight(.bold)
                    
                    Text(question.explanation)
                        .font(.body)
                    
                    Button(action: {
                        // Go to next question or finish quiz
                        if currentQuestionIndex < quiz.questions.count - 1 {
                            currentQuestionIndex += 1
                            selectedAnswerIndex = nil
                            isAnswerCorrect = nil
                            showingExplanation = false
                        } else {
                            // Quiz is finished, show completion screen
                            quizCompleted = true
                        }
                    }) {
                        Text(currentQuestionIndex < quiz.questions.count - 1 ? "Next Question" : "See Results")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .padding(.top, 10)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .shadow(radius: 5)
                .padding()
                .transition(.move(edge: .bottom))
                .animation(.spring(), value: showingExplanation)
            }
        }
        .onChange(of: quizCompleted) { completed in
            if completed {
                viewModel.saveData()
            }
        }
    }
    
    @ViewBuilder
    func completedQuizView(_ quiz: Quiz) -> some View {
        VStack(spacing: 25) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
                .padding()
            
            Text("Quiz Completed!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Great job! You've completed this week's Manul Monday Quiz.")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            VStack(spacing: 5) {
                Text("Your Score")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("\(quiz.score) / \(quiz.maxScore)")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(15)
            .padding(.horizontal)
            
            // Rewards gained
            VStack(alignment: .leading, spacing: 10) {
                Text("Rewards Earned:")
                    .font(.headline)
                
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.yellow)
                    
                    Text("\(50 + (quiz.score * 15)) coins")
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.orange)
                    
                    Text("\(25 + (quiz.score * 10)) XP")
                        .foregroundColor(.primary)
                    
                    Spacer()
                }
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .padding(.horizontal)
            
            Text("Come back next Monday for a new quiz!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top)
            
            Spacer()
        }
        .padding()
    }
    
    @ViewBuilder
    func noQuizView() -> some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar")
                .font(.system(size: 80))
                .foregroundColor(.gray)
                .padding()
            
            Text("No Quiz Available")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(spacing: 10) {
                Text("Manul Monday quizzes are available every Monday!")
                
                Text("Come back on Monday for your next educational quiz about Pallas cats and conservation.")
                    .multilineTextAlignment(.center)
                
                Text("Completing quizzes earns coins, XP, and helps you learn about these wonderful cats.")
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.top, 5)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(15)
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
    
    private func backgroundColor(for index: Int) -> Color {
        if selectedAnswerIndex == nil {
            return Color.white
        }
        
        if index == selectedAnswerIndex {
            return isAnswerCorrect ?? false ? Color.green : Color.red
        }
        
        if let quiz = viewModel.currentQuiz, 
           index == quiz.questions[currentQuestionIndex].correctAnswerIndex {
            return Color.green.opacity(0.5)
        }
        
        return Color.white
    }
} 