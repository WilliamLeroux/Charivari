//
//  BackgroundManager.swift
//  Charivari
//
//  Created by William Leroux on 2024-12-06.
//

import SwiftUI

class BackgroundManager: ObservableObject {
    static let shared = BackgroundManager()
    @Published var backgroundId: Int
    
    init() {
        if (UserDefaults.standard.object(forKey: "bgId") != nil) {
            backgroundId = UserDefaults.standard.integer(forKey: "bgId")
        } else {
            backgroundId = 0
        }
    }
    
    func setBackgroundId(id: Int) {
        backgroundId = id
        UserDefaults.standard.set(id, forKey: "bgId")
    }
    
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
