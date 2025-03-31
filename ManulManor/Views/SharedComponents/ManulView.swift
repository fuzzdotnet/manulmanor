import SwiftUI

// Improved manul view with SVG visuals
struct ManulView: View {
    let mood: Manul.Mood
    var wearingItems: [String] = [] // IDs of worn items
    var scaleFactor: CGFloat = 1.0 // New parameter for size adjustments
    
    // Placeholder: Check if a hat is being worn
    private var isWearingHat: Bool {
        // This logic needs refinement based on actual item data
        // For now, just check if any worn item ID contains "hat"
        wearingItems.contains { $0.contains("hat") } 
    }

    var body: some View {
        ZStack {
            // Main manul body using Image directly for simplicity
            Image(svgName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 180 * scaleFactor, height: 180 * scaleFactor)
            
            // Wearable items
            if isWearingHat {
                // Display hat item
                // In the future, can be more dynamic based on which hat is worn
                Image("hat_beanie")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100 * scaleFactor, height: 60 * scaleFactor)
                    .offset(y: -60 * scaleFactor)
            }
        }
    }
    
    // Determine which SVG file to load based on mood
    private var svgName: String {
        switch mood {
        case .happy:
            return "manul_happy"
        case .neutral:
            return "manul_neutral"
        case .sad:
            return "manul_sad"
        case .unhappy:
            return "manul_unhappy"
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        ManulView(mood: .happy)
            .frame(width: 200, height: 200)
        
        ManulView(mood: .neutral)
            .frame(width: 200, height: 200)
        
        ManulView(mood: .sad)
            .frame(width: 200, height: 200)
        
        ManulView(mood: .unhappy, scaleFactor: 0.5)
            .frame(width: 200, height: 200)
    }
    .padding()
} 