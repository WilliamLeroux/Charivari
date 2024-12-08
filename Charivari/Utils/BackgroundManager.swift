//
//  BackgroundManager.swift
//  Charivari
//
//  Created by William Leroux on 2024-12-06.
//

import SwiftUI

/// Gestionnaire du fond d'écran
class BackgroundManager: ObservableObject {
    static let shared = BackgroundManager() /// Singleton
    @Published var backgroundId: Int /// Background actuel
    
    init() {
        if (UserDefaults.standard.object(forKey: "bgId") != nil) {
            backgroundId = UserDefaults.standard.integer(forKey: "bgId")
        } else {
            backgroundId = 0
        }
    }
    
    
    /// Change le fond d'écran actuel
    /// - Parameter id: Id du background
    func setBackgroundId(id: Int) {
        backgroundId = id
        UserDefaults.standard.set(id, forKey: "bgId")
    }
    
    /// Retourne le fond d'écran actuel
    /// - Parameter id: Id du background
    /// - Returns: Image du background en ImageRessource
    func getBackgroundImage(id: Int) -> ImageResource {
        switch id {
            case 0 : return .background
            case 1 : return .background2
            case 2 : return .background3
            case 3 : return .background4
            case 4 : return .background5
            default : return .background
        }
    }
}
