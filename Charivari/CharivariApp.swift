//
//  CharivariApp.swift
//  Charivari
//
//  Created by William Leroux on 2024-11-26.
//

import SwiftUI

@main
struct CharivariApp: App {
    let network = NetworkMonitor.shared
    var body: some Scene {
        WindowGroup {
            MenuView(network: network)
        }
    }
}
