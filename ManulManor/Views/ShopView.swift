import SwiftUI

struct ShopView: View {
    @EnvironmentObject var viewModel: ManulViewModel
    @State private var selectedCategory: Item.ItemType = .furniture
    @State private var showingSubscriptionModal = false
    @State private var showingDonationModal = false
    
    var body: some View {
        VStack {
            // Header with coins
            HStack {
                Text("Shop")
                    .font(.title)
                    .fontWeight(.bold)
                
                Spacer()
                
                HStack {
                    Image(systemName: "dollarsign.circle.fill")
                        .foregroundColor(.yellow)
                    
                    Text("\(viewModel.manul.coins)")
                        .font(.headline)
                }
                .padding(8)
                .background(Color.white.opacity(0.9))
                .cornerRadius(20)
            }
            .padding()
            
            // Category selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(Item.ItemType.allCases, id: \.self) { category in
                        CategoryButton(
                            title: category.displayName,
                            isSelected: category == selectedCategory,
                            action: {
                                selectedCategory = category
                            }
                        )
                    }
                    
                    // Premium button
                    CategoryButton(
                        title: "Premium",
                        isSelected: false,
                        action: {
                            showingSubscriptionModal = true
                        }
                    )
                    
                    // Donate button
                    CategoryButton(
                        title: "Adopt Again",
                        isSelected: false,
                        action: {
                            showingDonationModal = true
                        }
                    )
                }
                .padding(.horizontal)
            }
            .padding(.bottom)
            
            // Items grid
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    // Filter items by selected category and level requirement
                    ForEach(availableItems) { item in
                        ShopItemView(
                            item: item,
                            isLocked: item.unlockLevel > viewModel.manul.level,
                            isPurchased: viewModel.inventory.contains(where: { $0.id == item.id && $0.isPurchased }),
                            canAfford: viewModel.manul.coins >= item.price
                        ) {
                            purchaseItem(item)
                        }
                    }
                }
                .padding()
            }
        }
        .sheet(isPresented: $showingSubscriptionModal) {
            SubscriptionView()
        }
        .sheet(isPresented: $showingDonationModal) {
            DonationView()
        }
    }
    
    // Items available in the selected category
    var availableItems: [Item] {
        Item.sampleItems.filter { item in
            item.type == selectedCategory
        }
    }
    
    func purchaseItem(_ item: Item) {
        // Grasshoppers are always free and available
        if item.id == "food_grasshoppers" {
            viewModel.showFeedback("Grasshoppers are always available for free!", interactionType: "info")
            return
        }

        // Remove redundant checks - ViewModel now handles all validation
        // guard viewModel.manul.coins >= item.price && item.unlockLevel <= viewModel.manul.level else {
        //     if viewModel.manul.coins < item.price {
        //          viewModel.showFeedback("Not enough coins!", interactionType: "error")
        //     } else if item.unlockLevel > viewModel.manul.level {
        //          viewModel.showFeedback("Requires Level \(item.unlockLevel)!", interactionType: "error")
        //     }
        //     return
        // }
        //
        // if !item.isConsumable {
        //     guard !viewModel.inventory.contains(where: { $0.id == item.id && $0.isPurchased }) else {
        //         viewModel.showFeedback("You already own this item!", interactionType: "info")
        //         return
        //     }
        // }

        // Attempt to purchase the item via the ViewModel
        viewModel.purchaseItem(item)
    }
}

struct SubscriptionView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Spacer()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                .padding()
            }
            
            Image(systemName: "star.circle.fill")
                .font(.system(size: 70))
                .foregroundColor(.yellow)
                .padding(.bottom)
            
            Text("Manor Club")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Become a Club Member and get exclusive benefits!")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Benefits
            VStack(alignment: .leading, spacing: 15) {
                BenefitRow(icon: "gift.fill", text: "Monthly exclusive item set")
                BenefitRow(icon: "star.fill", text: "50% Bonus XP")
                BenefitRow(icon: "dollarsign.circle.fill", text: "Double quiz rewards")
                BenefitRow(icon: "person.fill.checkmark", text: "Profile badge")
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .padding(.horizontal)
            
            // Price
            VStack {
                Text("$4.99 per month")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text("Cancel anytime")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            // Subscribe button
            Button(action: {
                // In a real app, this would initiate the subscription IAP
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Subscribe Now")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            
            Text("Subscription automatically renews unless canceled at least 24 hours before the end of the current period.")
                .font(.caption2)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.top, 10)
            
            Spacer()
        }
        .background(Color.gray.opacity(0.1).ignoresSafeArea())
    }
}

struct DonationView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Spacer()
                
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                }
                .padding()
            }
            
            Image(systemName: "heart.fill")
                .font(.system(size: 70))
                .foregroundColor(.red)
                .padding(.bottom)
            
            Text("Adopt Again")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Help protect real Pallas cats in the wild!")
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Conservation info
            Text("Your donation goes to conservation partners working to protect Pallas cat habitats and populations through research and education.")
                .font(.body)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color.white)
                .cornerRadius(15)
                .padding(.horizontal)
            
            // Donation tiers
            VStack(spacing: 15) {
                DonationTierButton(
                    title: "Kitten",
                    description: "Basic adoption package + in-game badge",
                    price: "$2.99"
                )
                
                DonationTierButton(
                    title: "Adult",
                    description: "Adoption + exclusive accessory pack",
                    price: "$8.99",
                    isRecommended: true
                )
                
                DonationTierButton(
                    title: "Guardian",
                    description: "Adoption + all accessories + rare habitat item",
                    price: "$14.99"
                )
            }
            .padding(.horizontal)
            
            Spacer()
            
            Text("100% of profits from Adopt Again purchases are donated to Pallas cat conservation organizations.")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 20)
        }
        .background(Color.gray.opacity(0.1).ignoresSafeArea())
    }
}

struct BenefitRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .font(.system(size: 20))
                .frame(width: 30, height: 30)
            
            Text(text)
                .font(.body)
            
            Spacer()
        }
    }
}

struct DonationTierButton: View {
    let title: String
    let description: String
    let price: String
    var isRecommended: Bool = false
    
    var body: some View {
        Button(action: {
            // In a real app, this would initiate the donation IAP
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(title)
                            .font(.headline)
                        
                        if isRecommended {
                            Text("Recommended")
                                .font(.caption)
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.orange)
                                .cornerRadius(10)
                        }
                    }
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text(price)
                    .font(.headline)
                    .fontWeight(.bold)
            }
            .padding()
            .background(Color.white)
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(isRecommended ? Color.orange : Color.clear, lineWidth: 2)
            )
            .shadow(color: isRecommended ? Color.orange.opacity(0.3) : Color.gray.opacity(0.2), radius: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
} 