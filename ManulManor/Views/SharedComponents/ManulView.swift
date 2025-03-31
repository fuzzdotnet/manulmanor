import SwiftUI

// Improved manul view with better visuals
struct ManulView: View {
    let mood: Manul.Mood
    var wearingItems: [String] = [] // IDs of worn items
    
    // Placeholder: Check if a hat is being worn
    private var isWearingHat: Bool {
        // This logic needs refinement based on actual item data
        // For now, just check if any worn item ID contains "hat"
        wearingItems.contains { $0.contains("hat") } 
    }

    var body: some View {
        // In a real implementation, this would use actual manul images for different moods
        ZStack {
            // Body
            Circle()
                .fill(moodColor(for: mood))
                .frame(width: 180, height: 180)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            
            // Fur texture overlay
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [moodColor(for: mood).opacity(0.7), moodColor(for: mood).opacity(0)]),
                        center: .center,
                        startRadius: 50,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
            
            // Ears
            HStack(spacing: 110) {
                Triangle()
                    .fill(moodColor(for: mood).darker())
                    .frame(width: 45, height: 45)
                    .rotationEffect(.degrees(15))
                    .offset(x: -10, y: -65)
                
                Triangle()
                    .fill(moodColor(for: mood).darker())
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

            // Wearables - Add on top
            if isWearingHat {
                // Placeholder Beanie
                Circle()
                    .fill(Color.red)
                    .frame(width: 60, height: 40)
                    .offset(y: -90) // Position above the head
                Circle()
                    .fill(Color.white)
                    .frame(width: 10, height: 10)
                    .offset(y: -110) // Pom-pom
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