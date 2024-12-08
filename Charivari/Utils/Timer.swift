//
//  Timer.swift
//  Charivari
//
//  Created by William Leroux on 2024-11-29.
//

import SwiftUI

/// Gestionnaire du temps
class TimerManager: ObservableObject {
    static let shared = TimerManager() /// Singleton
    private var timer = Timer() /// Timer
    @Published var time: Double = 0.0 /// Temps
    
    /// Lance le chronomètre
    func start() {
        timer.invalidate()
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    /// Arrête le chronomètre
    func stop() {
        timer.invalidate()
    }

    /// Réinitialise le temps du chronomètre
    func reset() {
        time = 0.0
    }
    
    /// Change le temps du chronomètre
    /// - Parameter time: Temps
    func setTime(time: Double)  {
        self.time = time
    }

    /// Met à jour le temps à chaque seconde
    @objc private func update() {
        time += 1.0
    }
    
    
    /// Retourne le temps formatté pour l'affichage
    /// - Returns: Temps formatté
    func formattedTime() -> String {
        String(format: "%02d:%02d", Int(time / 60), Int(time.truncatingRemainder(dividingBy: 60)))
    }
}
