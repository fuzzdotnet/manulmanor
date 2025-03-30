import SwiftUI

@main
struct ManulManorApp: App {
    @StateObject private var manulViewModel = ManulViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(manulViewModel)
        }
    }
} 