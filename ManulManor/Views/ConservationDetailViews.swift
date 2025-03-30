import SwiftUI

// Base detail view for conservation information
struct ConservationDetailView<Content: View>: View {
    @Environment(\.presentationMode) var presentationMode
    let title: String
    let headerImage: String
    let headerColor: Color
    let contentBody: Content // Store the content view directly
    
    // Initializer accepting a ViewBuilder closure for content
    init(title: String, headerImage: String, headerColor: Color, @ViewBuilder content: () -> Content) {
        self.title = title
        self.headerImage = headerImage
        self.headerColor = headerColor
        self.contentBody = content()
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header image/icon
                    ZStack {
                        Rectangle()
                            .fill(headerColor.opacity(0.2))
                            .frame(height: 200)
                        
                        Image(systemName: headerImage)
                            .font(.system(size: 70))
                            .foregroundColor(headerColor)
                    }
                    
                    // Use the stored content view
                    contentBody
                        .padding()
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}

// Conservation goals detail view
struct ConservationGoalsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ConservationDetailView(
            title: "Our Conservation Goals",
            headerImage: "shield.lefthalf.filled",
            headerColor: .blue
        ) {
            VStack(alignment: .leading, spacing: 20) {
                Group {
                    Text("Our Mission")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Manul Manor is committed to helping protect wild Pallas cats through awareness, education, and direct support for conservation programs.")
                        .padding(.bottom, 10)
                    
                    Text("The Pallas cat (Otocolobus manul) is currently classified as Near Threatened by the IUCN, with population declining due to habitat loss, poaching, and reduction in prey species.")
                }
                
                Divider()
                    .padding(.vertical, 10)
                
                Group {
                    Text("Conservation Goals")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    ConservationGoalRow(
                        icon: "megaphone.fill",
                        title: "Raising Awareness",
                        description: "Educating the public about Pallas cats and their conservation needs"
                    )
                    
                    ConservationGoalRow(
                        icon: "chart.bar.fill",
                        title: "Supporting Research",
                        description: "Funding scientific studies on Pallas cat populations, behavior, and habitat requirements"
                    )
                    
                    ConservationGoalRow(
                        icon: "person.3.fill",
                        title: "Community Initiatives",
                        description: "Working with local communities to promote co-existence with Pallas cats"
                    )
                    
                    ConservationGoalRow(
                        icon: "leaf.fill",
                        title: "Habitat Protection",
                        description: "Supporting efforts to preserve and restore critical Pallas cat habitats"
                    )
                }
                
                Divider()
                    .padding(.vertical, 10)
                
                Group {
                    Text("How We Contribute")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("A portion of all in-app purchases in Manul Manor goes directly to our conservation partners. Through your gameplay and purchases, you're helping real Pallas cats in the wild!")
                    
                    Text("We regularly review our conservation strategy to ensure we're making the greatest possible impact for Pallas cat conservation.")
                        .padding(.vertical, 10)
                }
            }
        }
    }
}

// Partner organizations detail view
struct PartnerOrganizationsView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ConservationDetailView(
            title: "Partner Organizations",
            headerImage: "building.2.fill",
            headerColor: .green
        ) {
            VStack(alignment: .leading, spacing: 20) {
                Text("Our Partners in Conservation")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Manul Manor is proud to support these organizations working on the frontlines of Pallas cat conservation.")
                    .padding(.bottom, 10)
                
                // Partner cards
                PartnerCard(
                    name: "International Pallas Cat Working Group",
                    description: "A network of researchers and conservationists dedicated to studying and protecting Pallas cats across their range.",
                    website: "www.pallascats.org"
                )
                
                PartnerCard(
                    name: "Snow Leopard Trust",
                    description: "Working to protect not only snow leopards but also other highland species including Pallas cats through community-based conservation.",
                    website: "www.snowleopard.org"
                )
                
                Divider()
                    .padding(.vertical, 10)
                
                Text("Partnership Impact")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Our partnerships have helped fund:")
                    .fontWeight(.medium)
                    .padding(.top, 5)
                
                // Impact items
                ImpactItem(text: "Camera trap studies monitoring wild Pallas cat populations")
                ImpactItem(text: "Educational programs for local communities and schools")
                ImpactItem(text: "Training for wildlife rangers and conservation staff")
                ImpactItem(text: "Habitat preservation initiatives across Central Asia")
                
                Divider()
                    .padding(.vertical, 10)
                
                Text("Want to learn more?")
                    .font(.headline)
                    .padding(.vertical, 5)
                
                Text("Visit our partners' websites to discover more about their work and how you can get involved beyond Manul Manor.")
            }
        }
    }
}

// Your impact detail view
struct YourImpactView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ConservationDetailView(
            title: "Your Impact",
            headerImage: "heart.fill",
            headerColor: .red
        ) {
            VStack(alignment: .leading, spacing: 20) {
                Text("Your Contribution Matters")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Through playing Manul Manor and making in-app purchases, you're directly contributing to Pallas cat conservation efforts around the world.")
                    .padding(.bottom, 10)
                
                // Impact statistics
                HStack(spacing: 20) {
                    ImpactStatCard(
                        value: "$15,000+",
                        label: "Donated",
                        icon: "dollarsign.circle.fill",
                        color: .green
                    )
                    
                    ImpactStatCard(
                        value: "25,000+",
                        label: "Players",
                        icon: "person.2.fill",
                        color: .blue
                    )
                }
                .padding(.vertical, 10)
                
                Divider()
                    .padding(.vertical, 10)
                
                Text("How Your Support Helps")
                    .font(.title2)
                    .fontWeight(.bold)
                
                ImpactExampleCard(
                    title: "Camera Traps",
                    description: "Each $25 raised funds a day of camera trap monitoring to study wild Pallas cat behavior and movements",
                    icon: "camera.fill",
                    color: .orange
                )
                
                ImpactExampleCard(
                    title: "Educational Programs",
                    description: "Every $50 helps create educational materials for schools in communities where Pallas cats live",
                    icon: "book.fill",
                    color: .blue
                )
                
                ImpactExampleCard(
                    title: "Conservation Support",
                    description: "$100 provides a week's funding for a local conservation officer monitoring and protecting Pallas cat habitats",
                    icon: "figure.walk",
                    color: .green
                )
                
                Divider()
                    .padding(.vertical, 10)
                
                Text("Adopt Again")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Want to make an even bigger impact? Consider making an \"Adopt Again\" purchase in the shop to provide additional support for our conservation partners.")
                    .padding(.bottom, 15)
                
                Button(action: {
                    // Would navigate to donation screen
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Visit the Shop")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
        }
    }
}

// MARK: - Supporting Components

// Conservation goal row component
struct ConservationGoalRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.blue)
                .frame(width: 26, height: 26)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 6)
    }
}

// Partner organization card
struct PartnerCard: View {
    let name: String
    let description: String
    let website: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(name)
                .font(.headline)
            
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: "link")
                    .foregroundColor(.blue)
                
                Text(website)
                    .font(.subheadline)
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.green.opacity(0.1))
        )
    }
}

// Impact item for bullet points
struct ImpactItem: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 16))
            
            Text(text)
                .font(.body)
            
            Spacer()
        }
        .padding(.vertical, 3)
    }
}

// Impact stat card
struct ImpactStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 28))
                .foregroundColor(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(color.opacity(0.1))
        )
    }
}

// Impact example card
struct ImpactExampleCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 15) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(color)
            }
            
            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        )
        .padding(.vertical, 5)
    }
} 