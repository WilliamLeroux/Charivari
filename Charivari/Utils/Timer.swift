//
//  Timer.swift
//  Charivari
//
//  Created by William Leroux on 2024-11-29.
//

import SwiftUI

class TimerManager: ObservableObject {
    static let shared = TimerManager()
    private var timer = Timer()
    @Published var time: Double = 0.0
    
    func start() {
        timer.invalidate()
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(update), userInfo: nil, repeats: true)
    }
    
    func stop() {
        timer.invalidate()
    }
    
    func setTime(time: Double)  {
        self.time += time
    }
    
    @objc private func update() {
        time += 1.0
    }
}
