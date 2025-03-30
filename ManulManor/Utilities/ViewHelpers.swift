import SwiftUI

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
// Updated to match ShopItemView logic
func iconFor(_ item: Item) -> String {
    switch item.type {
    case .food: return "fork.knife" // Changed from leaf.fill
    case .toy: return "star.fill"
    case .furniture: return "bed.double.fill"
    case .decoration: return "leaf.fill" // Changed from leaf.circle.fill
    case .hat: return "crown.fill"
    case .accessory: return "gift.fill" // Changed from sparkles
    }
}

// Helper function to determine color for an item based on type
func colorFor(item: Item) -> Color {
    switch item.type {
    case .food:
        return .orange
    case .toy:
        return .yellow
    case .furniture:
        return .brown
    case .decoration:
        return .green
    case .hat:
        return .purple
    case .accessory:
        return .pink
    }
}

// Extension for color manipulation
extension Color {
    func darker(by percentage: CGFloat = 0.2) -> Color {
        // Basic darkening, might need a more robust implementation
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        UIColor(self).getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return Color(UIColor(hue: hue, saturation: saturation, brightness: max(brightness - percentage, 0), alpha: alpha))
    }

    func lighter(by percentage: CGFloat = 0.2) -> Color {
        // Basic lightening, might need a more robust implementation
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        UIColor(self).getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return Color(UIColor(hue: hue, saturation: saturation, brightness: min(brightness + percentage, 1), alpha: alpha))
    }
}

// Note: The original actionAnimation function was a @ViewBuilder inside HomeView.
// Moving it here directly might not work if it relies on HomeView's state or properties.
// It's generally better to keep ViewBuilder functions within the View struct
// or encapsulate them in separate View structs if they are complex and reusable.
// For now, I'm omitting actionAnimation from this helper file. It might be better
// refactored into its own reusable View component later if needed.

// Similarly, the helper functions `foodIcon` and `foodColor` were specific to FoodSelectionView.
// It's better to keep them there or move them here if they are truly general-purpose.
// I'll leave them in FoodSelectionView for now. 