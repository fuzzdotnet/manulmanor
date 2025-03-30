import Foundation

struct QuizQuestion: Identifiable, Codable {
    var id = UUID()
    var question: String
    var options: [String]
    var correctAnswerIndex: Int
    var explanation: String
    
    var correctAnswer: String {
        return options[correctAnswerIndex]
    }
}

struct Quiz: Identifiable, Codable {
    var id = UUID()
    var title: String
    var date: Date
    var questions: [QuizQuestion]
    var isCompleted: Bool = false
    var score: Int = 0
    
    var maxScore: Int {
        return questions.count
    }
}

// Extension with sample quiz data
extension Quiz {
    static let sample = Quiz(
        title: "Manul Monday: Habitat & Survival",
        date: Date(),
        questions: [
            QuizQuestion(
                question: "Where do Pallas cats (manuls) primarily live?",
                options: ["Tropical rainforests", "Central Asian steppes", "Arctic tundra", "African savannas"],
                correctAnswerIndex: 1,
                explanation: "Pallas cats live in the cold, rocky steppes of Central Asia, including Mongolia, China, and parts of Russia."
            ),
            QuizQuestion(
                question: "Why do Pallas cats have such thick fur?",
                options: ["For camouflage", "To survive freezing temperatures", "To appear larger to predators", "For underwater swimming"],
                correctAnswerIndex: 1,
                explanation: "Pallas cats have extremely thick fur, which helps them survive in harsh, cold environments with temperatures that can drop well below freezing."
            ),
            QuizQuestion(
                question: "What conservation status are Pallas cats currently listed as?",
                options: ["Least Concern", "Near Threatened", "Endangered", "Critically Endangered"],
                correctAnswerIndex: 1,
                explanation: "Pallas cats are currently listed as Near Threatened on the IUCN Red List due to habitat loss and hunting."
            )
        ]
    )
    
    static func generateWeeklyQuiz() -> Quiz {
        // In a real app, this would pull from a larger question database or API
        // For now, we'll just return the sample quiz
        var newQuiz = sample
        newQuiz.date = Date()
        newQuiz.isCompleted = false
        newQuiz.score = 0
        return newQuiz
    }
} 