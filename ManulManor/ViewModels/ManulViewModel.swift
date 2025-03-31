import Foundation
import SwiftUI
import Combine

class ManulViewModel: ObservableObject {
    // Main properties
    @Published var manul: Manul
    @Published var inventory: [Item]
    @Published var placedItems: [Item] = []
    @Published var currentQuiz: Quiz?
    @Published var isOnboarding: Bool = false
    @Published var notificationPermissionGranted: Bool = false
    @Published var isSubscribed: Bool = false
    
    // Animation and interaction properties
    @Published var lastInteractionType: String = ""
    @Published var interactionFeedback: String = ""
    @Published var showInteractionFeedback: Bool = false
    @Published var recentRewards: [Reward] = []
    
    // Timers for automatic stat decay
    private var statsUpdateTimer: Timer?
    private var saveTimer: Timer?
    private var interactionFeedbackTimer: Timer?
    
    // User defaults keys
    private let manulKey = "manul_data"
    private let inventoryKey = "inventory_data"
    private let placedItemsKey = "placed_items_data"
    private let quizKey = "quiz_data"
    private let onboardingKey = "has_completed_onboarding"
    
    // Initialize with default values
    init() {
        // Load data using helper function
        let defaultManul = Manul.newManul(name: "")
        self.manul = ManulViewModel.loadData(forKey: manulKey, defaultValue: defaultManul)
        self.inventory = ManulViewModel.loadData(forKey: inventoryKey, defaultValue: Item.sampleItems.filter { $0.isPurchased })
        self.placedItems = ManulViewModel.loadData(forKey: placedItemsKey, defaultValue: [])

        // Check for onboarding condition
        if self.manul.id == defaultManul.id && self.manul.name.isEmpty { // Check if it's the default one
            self.isOnboarding = true
        }

        // Load quiz data (specific logic for default value)
        self.currentQuiz = {
            guard let data = UserDefaults.standard.data(forKey: quizKey) else { return nil }
            return try? JSONDecoder().decode(Quiz.self, from: data)
        }()

        // If no saved quiz, check if we need to create a new one (e.g., on Mondays)
        if self.currentQuiz == nil {
            let calendar = Calendar.current
            let weekday = calendar.component(.weekday, from: Date())
            if weekday == 2 { // Monday is 2 in Calendar.Component.weekday
                self.currentQuiz = Quiz.generateWeeklyQuiz()
                // Note: Consider if saving is needed immediately after generating a new quiz
            }
        }

        // Start timers
        startTimers()
    }
    
    // MARK: - Data Loading Helper
    
    private static func loadData<T: Decodable>(forKey key: String, defaultValue: @autoclosure () -> T) -> T {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decodedValue = try? JSONDecoder().decode(T.self, from: data) else {
            // Log decoding errors or missing data if needed
            // print("Could not load or decode data for key \(key). Using default value.")
            return defaultValue()
        }
        return decodedValue
    }
    
    // MARK: - Timer Functions
    
    private func startTimers() {
        // Update stats every 30 minutes
        statsUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1800, repeats: true) { [weak self] _ in
            self?.updateStats()
        }
        
        // Save data every 5 minutes
        saveTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.saveData()
        }
    }
    
    // MARK: - Pet Interaction Functions
    
    func feedManul(with foodItem: Item? = nil) {
        // Previous hunger value for feedback
        let previousHunger = manul.hunger
        
        // Set default food stats for grasshoppers
        var hungerIncrease = 0.2
        var happinessIncrease = 0.05
        var feedbackQuality = "basic"
        let foodName = foodItem?.name ?? "Grasshoppers"
        var usingGrasshoppers = true
        
        // Adjust stats based on food quality if a specific food is provided
        if let food = foodItem {
            usingGrasshoppers = food.id == "food_grasshoppers"
            
            switch food.id {
            case "food_grasshoppers":
                // Base stats already set
                break
            case "food_pika":
                hungerIncrease = 0.3
                happinessIncrease = 0.1
                feedbackQuality = "good"
            case "food_partridge":
                hungerIncrease = 0.4
                happinessIncrease = 0.15
                feedbackQuality = "good"
            case "food_marmot":
                hungerIncrease = 0.5
                happinessIncrease = 0.2
                feedbackQuality = "premium"
            case "food_chicken":
                hungerIncrease = 0.6
                happinessIncrease = 0.25
                feedbackQuality = "premium"
            case "food_fish":
                hungerIncrease = 0.7
                happinessIncrease = 0.3
                feedbackQuality = "super"
            default:
                break
            }
            
            // If not using grasshoppers, consume one unit of the food
            if !usingGrasshoppers {
                consumeItem(food)
            }
        }
        
        // Update stats
        manul.hunger = min(1.0, manul.hunger + hungerIncrease)
        manul.lastFed = Date()
        manul.happiness = min(1.0, manul.happiness + happinessIncrease)
        
        // Determine feedback based on improvement and food quality
        if feedbackQuality == "super" {
            showFeedback("\(manul.name) is ecstatic about the \(foodName)!", interactionType: "feed")
        } else if feedbackQuality == "premium" {
            showFeedback("\(manul.name) absolutely loves the \(foodName)!", interactionType: "feed")
        } else if feedbackQuality == "good" {
            showFeedback("Yum! \(manul.name) really enjoys the \(foodName)!", interactionType: "feed")
        } else if manul.hunger >= 0.9 {
            showFeedback("\(manul.name) is full!", interactionType: "feed")
        } else {
            showFeedback("\(manul.name) eats the \(foodName)", interactionType: "feed")
        }
        
        // Add XP for interacting
        addXP(amount: 5)
        
        // Track interaction
        lastInteractionType = "feed"
        
        saveData()
    }
    
    func cleanManul() {
        // Previous hygiene value for feedback
        let previousHygiene = manul.hygiene
        
        // Update stats
        manul.hygiene = 1.0
        manul.lastCleaned = Date()
        
        // Determine feedback based on improvement
        if 1.0 - previousHygiene > 0.3 {
            showFeedback("\(manul.name) feels fresh and clean!", interactionType: "clean")
        } else if previousHygiene > 0.8 {
            showFeedback("\(manul.name) was already quite clean", interactionType: "clean")
        } else {
            showFeedback("\(manul.name) is now clean and happy", interactionType: "clean")
        }
        
        // Add XP for interacting
        addXP(amount: 5)
        
        // Track interaction
        lastInteractionType = "clean"
        
        saveData()
    }
    
    func playWithManul() {
        // Previous happiness value for feedback
        let previousHappiness = manul.happiness
        
        // Update stats
        manul.happiness = min(1.0, manul.happiness + 0.3)
        manul.lastInteraction = Date()
        
        // Determine feedback based on improvement
        if manul.happiness - previousHappiness > 0.25 {
            showFeedback("\(manul.name) is having so much fun!", interactionType: "play")
        } else if manul.happiness >= 0.9 {
            showFeedback("\(manul.name) is very happy!", interactionType: "play")
        } else {
            showFeedback("\(manul.name) enjoyed playing with you", interactionType: "play")
        }
        
        // Add XP for interacting
        addXP(amount: 10)
        
        // Track interaction
        lastInteractionType = "play"
        
        saveData()
    }
    
    // New function to show feedback with auto-dismissal
    func showFeedback(_ message: String, interactionType: String) {
        self.interactionFeedback = message
        self.showInteractionFeedback = true
        self.lastInteractionType = interactionType
        
        // Cancel existing timer if there is one
        interactionFeedbackTimer?.invalidate()
        
        // Set timer to hide feedback after delay
        interactionFeedbackTimer = Timer.scheduledTimer(withTimeInterval: 2.5, repeats: false) { [weak self] _ in
            withAnimation {
                self?.showInteractionFeedback = false
            }
        }
    }
    
    // MARK: - Inventory Functions
    
    func purchaseItem(_ item: Item) {
        // 1. Check if already owned (for non-consumables)
        if !item.isConsumable && inventory.contains(where: { $0.id == item.id && $0.isPurchased }) {
            showFeedback("You already own \(item.name)", interactionType: "info")
            return
        }

        // 2. Check level requirement
        guard item.unlockLevel <= manul.level else {
            showFeedback("\(item.name) requires Level \(item.unlockLevel)", interactionType: "purchase_failed")
            return
        }

        // 3. Check sufficient coins (already existing check)
        guard manul.coins >= item.price else {
            showFeedback("Not enough coins to buy \(item.name)", interactionType: "purchase_failed")
            return
        }

        // ---- Purchase logic proceeds if checks pass ----

        // Deduct coins
        manul.coins -= item.price
        
        // Add item to inventory
        var updatedItem = item
        updatedItem.isPurchased = true
        
        // Handle different purchase logic for consumable vs. non-consumable items
        if item.isConsumable {
            // For consumable items, increase quantity
            if let index = inventory.firstIndex(where: { $0.id == item.id }) {
                // Item exists, increment quantity
                inventory[index].quantity += 1
            } else {
                // New item, add with quantity 1
                updatedItem.quantity = 1
                inventory.append(updatedItem)
            }
        } else {
            // For non-consumable items, just mark as purchased
            if let index = inventory.firstIndex(where: { $0.id == item.id }) {
                inventory[index] = updatedItem
            } else {
                inventory.append(updatedItem)
            }
        }
        
        // Show feedback
        if item.isConsumable {
            let quantityText = getItemQuantity(item.id) > 1 ? "\(getItemQuantity(item.id)) available" : ""
            showFeedback("Purchased \(item.name)! \(quantityText)", interactionType: "purchase_success")
        } else {
            showFeedback("Purchased \(item.name)!", interactionType: "purchase_success")
        }
        
        saveData()
    }
    
    func consumeItem(_ item: Item) {
        guard item.isConsumable else { return }

        if var foundItem = inventory.first(where: { $0.id == item.id }) {
            foundItem.quantity -= 1
            if foundItem.quantity <= 0 {
                // Remove if quantity is zero and it's not grasshoppers
                if item.id != "food_grasshoppers" {
                    inventory.removeAll { $0.id == item.id }
                }
            } else {
                // Update quantity in inventory
                if let index = inventory.firstIndex(where: { $0.id == item.id }) {
                    inventory[index] = foundItem
                }
            }
            saveData()
        }
    }
    
    // Add multiple units of a consumable item
    func addItems(_ item: Item, quantity: Int) {
        guard item.isConsumable else { return }
        
        if let index = inventory.firstIndex(where: { $0.id == item.id }) {
            inventory[index].quantity += quantity
        } else {
            var newItem = item
            newItem.isPurchased = true
            newItem.quantity = quantity
            inventory.append(newItem)
        }
        
        saveData()
    }
    
    // Get the quantity of a specific item
    func getItemQuantity(_ itemId: String) -> Int {
        if let item = inventory.first(where: { $0.id == itemId }) {
            return item.quantity
        }
        return 0
    }
    
    // Check if player can use a specific item
    func canUseItem(_ item: Item) -> Bool {
        // For non-consumable items, just check if purchased
        if !item.isConsumable {
            return inventory.contains(where: { $0.id == item.id && $0.isPurchased })
        }
        
        // For consumable items, check quantity
        // Special case for grasshoppers which are always available
        if item.id == "food_grasshoppers" {
            return true
        }
        
        return getItemQuantity(item.id) > 0
    }
    
    func placeItem(_ item: Item, at position: CGPoint) {
        var updatedItem = item
        updatedItem.position = position
        
        if let index = placedItems.firstIndex(where: { $0.id == item.id }) {
            placedItems[index] = updatedItem
        } else {
            placedItems.append(updatedItem)
        }
        
        // Improve happiness slightly when decorating
        manul.happiness = min(1.0, manul.happiness + 0.05)
        
        // Show feedback
        showFeedback("\(manul.name) likes the new decoration!", interactionType: "place_item")
        
        saveData()
    }
    
    func removeItem(_ item: Item) {
        placedItems.removeAll { $0.id == item.id }
        
        // Show feedback
        showFeedback("Removed \(item.name)", interactionType: "remove_item")
        
        saveData()
    }
    
    // New function to wear an item
    func wearItem(_ item: Item) {
        guard item.type == .hat || item.type == .accessory else { return } // Only allow wearable types
        
        // Basic implementation: Only one hat/accessory at a time for now
        // Remove any existing item of the same type before wearing the new one
        manul.wearingItems.removeAll { itemId in
            guard let existingItem = inventory.first(where: { $0.id == itemId }) else { return false }
            return existingItem.type == item.type
        }
        
        manul.wearingItems.append(item.id)
        objectWillChange.send() // Notify views of change
        saveData()
    }

    // New function to remove a worn item
    func removeWornItem(_ item: Item) {
        manul.wearingItems.removeAll { $0 == item.id }
        objectWillChange.send() // Notify views of change
        saveData()
    }
    
    // MARK: - Quiz Functions
    
    func checkForWeeklyQuiz() {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        
        // If it's Monday (weekday == 2) and we don't have a quiz or it's completed
        if weekday == 2 && (currentQuiz == nil || currentQuiz!.isCompleted) {
            currentQuiz = Quiz.generateWeeklyQuiz()
            saveData()
            
            // Send notification if permission granted
            if notificationPermissionGranted {
                scheduleQuizNotification()
            }
        }
    }
    
    func submitQuizAnswer(questionIndex: Int, answerIndex: Int) -> Bool {
        guard var quiz = currentQuiz, questionIndex < quiz.questions.count else { return false }
        
        let isCorrect = quiz.questions[questionIndex].correctAnswerIndex == answerIndex
        
        if isCorrect {
            quiz.score += 1
        }
        
        // If this is the last question, mark the quiz as completed
        if questionIndex == quiz.questions.count - 1 {
            quiz.isCompleted = true
            
            // Reward player for completing the quiz
            let baseReward = 50
            let bonusPerCorrect = 15
            let coinReward = baseReward + (quiz.score * bonusPerCorrect)
            let xpReward = 25 + (quiz.score * 10)
            
            // Add rewards
            let coinRewardObj = Reward(type: .coins, amount: coinReward, timestamp: Date())
            let xpRewardObj = Reward(type: .xp, amount: xpReward, timestamp: Date())
            recentRewards.append(coinRewardObj)
            recentRewards.append(xpRewardObj)
            
            // Award coins
            manul.coins += coinReward
            
            // Award XP
            addXP(amount: xpReward)
            
            // Show feedback
            showFeedback("Quiz completed! Earned \(coinReward) coins and \(xpReward) XP", interactionType: "quiz_completed")
        }
        
        currentQuiz = quiz
        saveData()
        
        return isCorrect
    }
    
    // MARK: - Progress Functions
    
    func addXP(amount: Int) {
        manul.xp += amount
        
        // Check for level up
        let xpNeededForNextLevel = manul.level * 100
        
        if manul.xp >= xpNeededForNextLevel {
            manul.level += 1
            manul.xp -= xpNeededForNextLevel
            
            // Give level up reward
            let coinReward = 50 * manul.level
            manul.coins += coinReward
            
            // Add to recent rewards
            let levelUpReward = Reward(type: .levelUp, amount: manul.level, timestamp: Date())
            let coinRewardObj = Reward(type: .coins, amount: coinReward, timestamp: Date())
            recentRewards.append(levelUpReward)
            recentRewards.append(coinRewardObj)
            
            // Show feedback
            showFeedback("Level Up! \(manul.name) is now level \(manul.level). Earned \(coinReward) coins!", interactionType: "level_up")
        }
        
        saveData()
    }
    
    // Clear recent rewards after they've been displayed
    func clearRecentRewards() {
        recentRewards.removeAll()
    }
    
    // MARK: - Utility Functions
    
    private func updateStats() {
        // Calculate time since last interactions
        let now = Date()
        let hoursSinceLastFed = now.timeIntervalSince(manul.lastFed) / 3600
        let hoursSinceLastCleaned = now.timeIntervalSince(manul.lastCleaned) / 3600
        let hoursSinceLastInteraction = now.timeIntervalSince(manul.lastInteraction) / 3600
        
        // Decay hunger (about 25% per 24 hours)
        let hungerDecay = min(manul.hunger, Double(hoursSinceLastFed) * 0.01)
        manul.hunger -= hungerDecay
        
        // Decay hygiene (about 20% per 24 hours)
        let hygieneDecay = min(manul.hygiene, Double(hoursSinceLastCleaned) * 0.008)
        manul.hygiene -= hygieneDecay
        
        // Decay happiness (about 15% per 24 hours)
        let happinessDecay = min(manul.happiness, Double(hoursSinceLastInteraction) * 0.006)
        manul.happiness -= happinessDecay
        
        saveData()
    }
    
    func generateAdoptionCertificate() -> UIImage {
        // In a real implementation, this would render a certificate using Core Graphics or similar
        // For now, we're just returning a placeholder
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 800, height: 600))
        
        let image = renderer.image { context in
            // Improved certificate styling
            
            // Background texture
            let backgroundPattern = UIColor(red: 0.95, green: 0.93, blue: 0.88, alpha: 1.0)
            backgroundPattern.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 800, height: 600))
            
            // Border
            let borderColor = UIColor(red: 0.47, green: 0.33, blue: 0.28, alpha: 1.0)
            borderColor.setStroke()
            let borderWidth: CGFloat = 8
            let borderRect = CGRect(x: borderWidth/2, y: borderWidth/2, width: 800-borderWidth, height: 600-borderWidth)
            context.stroke(borderRect.insetBy(dx: 10, dy: 10))
            
            // Inner content area
            UIColor.white.withAlphaComponent(0.6).setFill()
            let contentRect = CGRect(x: 40, y: 40, width: 720, height: 520)
            let contentPath = UIBezierPath(roundedRect: contentRect, cornerRadius: 12)
            contentPath.fill()
            
            // Title
            let titleFont = UIFont.systemFont(ofSize: 36, weight: .bold)
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: titleFont,
                .foregroundColor: borderColor
            ]
            
            let titleString = "Manul Adoption Certificate"
            let titleSize = titleString.size(withAttributes: titleAttributes)
            let titleRect = CGRect(x: 400 - titleSize.width/2, y: 70, width: titleSize.width, height: titleSize.height)
            titleString.draw(in: titleRect, withAttributes: titleAttributes)
            
            // Decorative elements
            borderColor.withAlphaComponent(0.2).setFill()
            let paw1 = UIBezierPath(ovalIn: CGRect(x: 80, y: 60, width: 40, height: 40))
            paw1.fill()
            
            let paw2 = UIBezierPath(ovalIn: CGRect(x: 680, y: 60, width: 40, height: 40))
            paw2.fill()
            
            // Content
            let contentFont = UIFont.systemFont(ofSize: 24)
            let contentAttributes: [NSAttributedString.Key: Any] = [
                .font: contentFont,
                .foregroundColor: UIColor.black
            ]
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            
            let nameString = "This certifies that \(self.manul.name) has been adopted by:"
            let nameRect = CGRect(x: 100, y: 170, width: 600, height: 50)
            nameString.draw(in: nameRect, withAttributes: contentAttributes)
            
            let playerNameString = "Player Name"
            let playerNameRect = CGRect(x: 100, y: 230, width: 600, height: 50)
            playerNameString.draw(in: playerNameRect, withAttributes: contentAttributes)
            
            let dateString = "On \(dateFormatter.string(from: Date()))"
            let dateRect = CGRect(x: 100, y: 290, width: 600, height: 50)
            dateString.draw(in: dateRect, withAttributes: contentAttributes)
            
            // Conservation fact
            let factFont = UIFont.italicSystemFont(ofSize: 18)
            let factAttributes: [NSAttributedString.Key: Any] = [
                .font: factFont,
                .foregroundColor: UIColor.darkGray
            ]
            
            let factString = "Pallas cats are listed as Near Threatened due to habitat loss and hunting."
            let factRect = CGRect(x: 100, y: 400, width: 600, height: 50)
            factString.draw(in: factRect, withAttributes: factAttributes)
            
            // Footer
            let footerFont = UIFont.systemFont(ofSize: 14)
            let footerAttributes: [NSAttributedString.Key: Any] = [
                .font: footerFont,
                .foregroundColor: UIColor.gray
            ]
            
            let footerString = "www.manulmanor.com - #ManulMonday"
            let footerRect = CGRect(x: 100, y: 500, width: 600, height: 30)
            footerString.draw(in: footerRect, withAttributes: footerAttributes)
        }
        
        return image
    }
    
    private func scheduleQuizNotification() {
        // This would typically use UNUserNotificationCenter
        // Placeholder implementation
    }
    
    // MARK: - Data Persistence
    
    func saveData() {
        let encoder = JSONEncoder()
        
        if let encodedManul = try? encoder.encode(manul) {
            UserDefaults.standard.set(encodedManul, forKey: manulKey)
        }
        
        if let encodedInventory = try? encoder.encode(inventory) {
            UserDefaults.standard.set(encodedInventory, forKey: inventoryKey)
        }
        
        if let encodedPlacedItems = try? encoder.encode(placedItems) {
            UserDefaults.standard.set(encodedPlacedItems, forKey: placedItemsKey)
        }
        
        if let quiz = currentQuiz, let encodedQuiz = try? encoder.encode(quiz) {
            UserDefaults.standard.set(encodedQuiz, forKey: quizKey)
        }
        
        UserDefaults.standard.set(!isOnboarding, forKey: onboardingKey)
    }
    
    func completeOnboarding(withManulName name: String) {
        manul.name = name
        isOnboarding = false
        saveData()
        
        // Show welcome feedback
        showFeedback("Welcome to Manul Manor, \(name)!", interactionType: "onboarding_complete")
    }
}

// Reward struct for tracking and displaying rewards
struct Reward: Identifiable, Equatable {
    var id = UUID()
    var type: RewardType
    var amount: Int
    var timestamp: Date
    
    static func == (lhs: Reward, rhs: Reward) -> Bool {
        return lhs.id == rhs.id
    }
    
    enum RewardType {
        case coins, xp, levelUp, item
        
        var icon: String {
            switch self {
            case .coins: return "dollarsign.circle.fill"
            case .xp: return "star.fill"
            case .levelUp: return "arrow.up.circle.fill"
            case .item: return "gift.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .coins: return .yellow
            case .xp: return .orange
            case .levelUp: return .green
            case .item: return .purple
            }
        }
    }
} 