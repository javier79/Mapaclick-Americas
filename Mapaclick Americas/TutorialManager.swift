//
//  TutorialManager.swift
//  mapaclick
//
//  Tutorial display tracking manager
//

import Foundation

class TutorialManager {
    
    // UserDefaults key for tracking tutorial count
    private static let tutorialCountKey = "gameplayTutorialCount"
    
    // Maximum number of times to show tutorial
    private static let maxTutorialDisplays = 3
    
    /// Check if tutorial should be shown
    static func shouldShowTutorial() -> Bool {
        let count = UserDefaults.standard.integer(forKey: tutorialCountKey)
        return count < maxTutorialDisplays
    }
    
    /// Increment tutorial display count
    static func incrementTutorialCount() {
        let currentCount = UserDefaults.standard.integer(forKey: tutorialCountKey)
        UserDefaults.standard.set(currentCount + 1, forKey: tutorialCountKey)
        UserDefaults.standard.synchronize()
    }
    
    /// Get current tutorial display count
    static func getTutorialCount() -> Int {
        return UserDefaults.standard.integer(forKey: tutorialCountKey)
    }
    
    /// Reset tutorial count (for testing/debugging)
    static func resetTutorialCount() {
        UserDefaults.standard.removeObject(forKey: tutorialCountKey)
        UserDefaults.standard.synchronize()
    }
}
