import SwiftUI
import WebKit

struct SVGImageView: UIViewRepresentable {
    let name: String
    var tintColor: UIColor? = nil
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.backgroundColor = UIColor.clear
        webView.isOpaque = false
        webView.scrollView.isScrollEnabled = false
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        if let svgURL = Bundle.main.url(forResource: name, withExtension: "svg") {
            do {
                var svgString = try String(contentsOf: svgURL)
                
                // If tint color is provided, inject a CSS style to override fill colors
                if let tintColor = tintColor {
                    let hexColor = hexString(from: tintColor)
                    let styleTag = "<style>path, circle, ellipse, rect, polygon { fill: #\(hexColor); }</style>"
                    
                    if let headEndIndex = svgString.range(of: "</svg>")?.lowerBound {
                        svgString.insert(contentsOf: styleTag, at: headEndIndex)
                    }
                }
                
                webView.loadHTMLString(svgString, baseURL: nil)
            } catch {
                print("Error loading SVG: \(error)")
            }
        } else {
            print("SVG file not found: \(name).svg")
        }
    }
    
    // Helper function to convert UIColor to hex string
    private func hexString(from color: UIColor) -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return String(
            format: "%02X%02X%02X",
            Int(r * 255),
            Int(g * 255),
            Int(b * 255)
        )
    }
}

// For SwiftUI preview
#Preview {
    SVGImageView(name: "happy")
        .frame(width: 100, height: 100)
        .preferredColorScheme(.light)
} 