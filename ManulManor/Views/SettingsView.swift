import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var viewModel: ManulViewModel
    @State private var showingRenameDialog = false
    @State private var newManulName = ""
    @State private var notificationsEnabled = true
    @State private var soundEnabled = true
    @State private var showingPrivacyPolicy = false
    @State private var showingTermsOfService = false
    @State private var showingAbout = false
    
    var body: some View {
        NavigationView {
            List {
                // Manul info section
                Section(header: Text("Manul Information")) {
                    VStack(alignment: .center, spacing: 10) {
                        // In a real app, this would be the manul image
                        Circle()
                            .fill(Color.orange.opacity(0.5))
                            .frame(width: 100, height: 100)
                            .overlay(
                                Image(systemName: "pawprint.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                            )
                            .padding(.top)
                        
                        Text(viewModel.manul.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("Level \(viewModel.manul.level)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        // XP Progress
                        let xpNeededForNextLevel = viewModel.manul.level * 100
                        let progress = Double(viewModel.manul.xp) / Double(xpNeededForNextLevel)
                        
                        VStack(alignment: .leading, spacing: 5) {
                            HStack {
                                Text("XP: \(viewModel.manul.xp)/\(xpNeededForNextLevel)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                            }
                            
                            ProgressView(value: progress)
                                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                .frame(height: 10)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    .frame(maxWidth: .infinity)
                    
                    Button(action: {
                        newManulName = viewModel.manul.name
                        showingRenameDialog = true
                    }) {
                        HStack {
                            Text("Rename Manul")
                            Spacer()
                            Image(systemName: "pencil")
                        }
                    }
                }
                
                // Notifications
                Section(header: Text("Notifications")) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                        .onChange(of: notificationsEnabled) { newValue in
                            viewModel.notificationPermissionGranted = newValue
                            // In a real app, this would request notification permissions
                        }
                    
                    Toggle("Daily Care Reminders", isOn: .constant(true))
                        .disabled(!notificationsEnabled)
                    
                    Toggle("Quiz Reminders", isOn: .constant(true))
                        .disabled(!notificationsEnabled)
                }
                
                // Audio
                Section(header: Text("Audio")) {
                    Toggle("Sound Effects", isOn: $soundEnabled)
                    
                    Toggle("Background Music", isOn: .constant(false))
                }
                
                // Account
                Section(header: Text("Account")) {
                    NavigationLink(destination: Text("Subscription Management")) {
                        HStack {
                            Text("Subscription")
                            Spacer()
                            Text(viewModel.isSubscribed ? "Active" : "Not Subscribed")
                                .foregroundColor(viewModel.isSubscribed ? .green : .secondary)
                        }
                    }
                    
                    Button(action: {
                        // In a real app, this would open the App Store for rating
                    }) {
                        HStack {
                            Text("Rate Manul Manor")
                            Spacer()
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    Button(action: {
                        // In a real app, this would configure the share sheet
                    }) {
                        HStack {
                            Text("Share with Friends")
                            Spacer()
                            Image(systemName: "square.and.arrow.up")
                        }
                    }
                }
                
                // Support
                Section(header: Text("Support & Information")) {
                    Button(action: {
                        showingAbout = true
                    }) {
                        HStack {
                            Text("About")
                            Spacer()
                            Image(systemName: "info.circle")
                        }
                    }
                    
                    Button(action: {
                        showingPrivacyPolicy = true
                    }) {
                        HStack {
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "doc.text")
                        }
                    }
                    
                    Button(action: {
                        showingTermsOfService = true
                    }) {
                        HStack {
                            Text("Terms of Service")
                            Spacer()
                            Image(systemName: "doc.text")
                        }
                    }
                    
                    Link(destination: URL(string: "https://manulmanor.com/support")!) {
                        HStack {
                            Text("Contact Support")
                            Spacer()
                            Image(systemName: "envelope")
                        }
                    }
                }
                
                // App info
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Settings")
            .alert("Rename Your Manul", isPresented: $showingRenameDialog) {
                TextField("Enter new name", text: $newManulName)
                
                Button("Cancel", role: .cancel) { }
                
                Button("Save") {
                    if !newManulName.isEmpty {
                        viewModel.manul.name = newManulName
                        viewModel.saveData()
                    }
                }
            } message: {
                Text("Choose a new name for your Pallas cat.")
            }
            .sheet(isPresented: $showingAbout) {
                AboutView()
            }
            .sheet(isPresented: $showingPrivacyPolicy) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Privacy Policy")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding()
                        
                        Text("This is a placeholder for the Privacy Policy. In a real app, this would contain complete privacy information about data collection, usage, and protection.")
                            .padding(.horizontal)
                        
                        Spacer()
                    }
                }
            }
            .sheet(isPresented: $showingTermsOfService) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Terms of Service")
                            .font(.title)
                            .fontWeight(.bold)
                            .padding()
                        
                        Text("This is a placeholder for the Terms of Service. In a real app, this would contain the complete terms governing the use of the application.")
                            .padding(.horizontal)
                        
                        Spacer()
                    }
                }
            }
        }
    }
}

struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack {
                    Image(systemName: "pawprint.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.orange)
                        .padding()
                    
                    Text("Manul Manor")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Virtual pet app with a mission")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // About content
                VStack(alignment: .leading, spacing: 15) {
                    GroupBox(label: Text("About Pallas Cats").font(.headline)) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Pallas cats (Otocolobus manul), also called manuls, are small wild cats native to the steppes and mountains of Central Asia.")
                                .padding(.top, 5)
                            
                            Text("These adorable felines are currently listed as Near Threatened on the IUCN Red List due to habitat loss and hunting.")
                            
                            Text("They have a distinctive appearance with round pupils (unlike other small cats), a flattened face, and extremely thick fur to withstand harsh winters.")
                        }
                        .font(.body)
                        .padding(.horizontal, 5)
                    }
                    .padding(.horizontal)
                    
                    GroupBox(label: Text("Our Mission").font(.headline)) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Manul Manor is designed to raise awareness about Pallas cat conservation through engaging, educational gameplay.")
                                .padding(.top, 5)
                            
                            Text("A portion of all proceeds from in-app purchases is donated to conservation organizations working to protect these unique cats and their habitats.")
                            
                            Text("By playing Manul Manor, you're helping to support real-world conservation efforts!")
                        }
                        .font(.body)
                        .padding(.horizontal, 5)
                    }
                    .padding(.horizontal)
                    
                    GroupBox(label: Text("Credits").font(.headline)) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Developed by: Manul Manor Team")
                                .padding(.top, 5)
                            
                            Text("Conservation Partners: International Pallas Cat Working Group, Snow Leopard Trust")
                            
                            Text("Special Thanks: All our players who help support Pallas cat conservation efforts!")
                        }
                        .font(.body)
                        .padding(.horizontal, 5)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
            }
        }
    }
} 