import SwiftUI

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