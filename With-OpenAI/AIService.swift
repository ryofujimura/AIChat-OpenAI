import SwiftUI

class AIService: ObservableObject {
    @Published var isLoading = false
    
    func generateMotivationalMessage() async -> String {
        await MainActor.run {
            isLoading = true
        }
        
        // Simulate AI processing time
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        
        let motivationalMessages = [
            "You are stronger than you think! 💪✨",
            "Every day is a new opportunity to shine! 🌟",
            "Believe in yourself and amazing things will happen! 🚀",
            "Your potential is limitless! Keep pushing forward! ⭐",
            "Today is your day to make magic happen! ✨",
            "You've got this! Trust the process! 🌈",
            "Success is just around the corner! Keep going! 🎯",
            "Your dreams are worth fighting for! 💖",
            "Every step forward is progress! 🏃‍♀️",
            "You are capable of incredible things! 🌟",
            "Stay positive and watch miracles happen! ✨",
            "Your journey is unique and beautiful! 🌸",
            "Keep believing in yourself! You're amazing! 💪",
            "Today's challenges are tomorrow's strengths! 🌈",
            "You have the power to create your own happiness! 🌟"
        ]
        
        await MainActor.run {
            isLoading = false
        }
        
        return motivationalMessages.randomElement() ?? "You are amazing! Keep going! ✨"
    }
}
