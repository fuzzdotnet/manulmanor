import SwiftUI

struct NativeSVGImageView: View {
    let name: String
    var tintColor: Color? = nil
    
    var body: some View {
        if let tintColor = tintColor {
            Image(name)
                .renderingMode(.template)
                .foregroundColor(tintColor)
        } else {
            Image(name)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        NativeSVGImageView(name: "manul_happy")
            .frame(width: 100, height: 100)
        
        NativeSVGImageView(name: "manul_happy", tintColor: .blue)
            .frame(width: 100, height: 100)
    }
} 