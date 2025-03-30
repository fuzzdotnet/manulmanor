import SwiftUI

struct FeedbackView: View {
    let message: String
    let type: FeedbackType
    
    @State private var opacity: Double = 0
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: type.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 32, height: 32)
                .background(type.color)
                .clipShape(Circle())
            
            // Message
            Text(message)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color(red: 0.25, green: 0.25, blue: 0.3))
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
            
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
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeOut(duration: 0.3)) {
                opacity = 1.0
            }
        }
    }
    
    enum FeedbackType {
        case success, warning, error, info
        
        var color: Color {
            switch self {
            case .success: return Color.green
            case .warning: return Color.orange
            case .error: return Color.red
            case .info: return Color.blue
            }
        }
        
        var icon: String {
            switch self {
            case .success: return "checkmark"
            case .warning: return "exclamationmark"
            case .error: return "xmark"
            case .info: return "info"
            }
        }
    }
}

// Extension to determine feedback type from interaction type
extension FeedbackView.FeedbackType {
    static func from(interactionType: String) -> FeedbackView.FeedbackType {
        switch interactionType {
        case "feed", "clean", "play", "purchase_success", "place_item", "wear_item", "level_up", "quiz_completed", "onboarding_complete":
            return .success
        case "purchase_failed":
            return .error
        case "remove_item", "remove_worn_item":
            return .info
        default:
            return .info
        }
    }
}

// Animation modifier for feedback
struct FeedbackAnimationModifier: ViewModifier {
    let show: Bool
    
    func body(content: Content) -> some View {
        content
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: show)
    }
}

extension View {
    func feedbackAnimation(show: Bool) -> some View {
        modifier(FeedbackAnimationModifier(show: show))
    }
}

// Preview
struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            FeedbackView(message: "Mittens is now clean and happy!", type: .success)
            
            FeedbackView(message: "Not enough coins to buy this item", type: .error)
            
            FeedbackView(message: "Quiz completed! You earned 75 coins", type: .success)
            
            FeedbackView(message: "Removed hat from inventory", type: .info)
        }
        .padding(20)
        .background(Color(red: 0.95, green: 0.95, blue: 0.97))
        .previewLayout(.sizeThatFits)
    }
} 