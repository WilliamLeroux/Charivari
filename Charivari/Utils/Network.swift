//
//  NetworkMonitor.swift
//  Charivari
//
//  Created by William Leroux on 2024-11-28.
//

import SwiftUI
import Network

/// Classe s'occupant du réseau
class NetworkMonitor : ObservableObject{
    static let shared = NetworkMonitor() /// Singleton
    private let monitor = NWPathMonitor() /// Moniteur du réseau
    @Published var connected = false /// Booléen indiquant si l'utilisateur à du réseau
    weak var delegate: NetworkDelegate? /// Délégué
    
    init() {
        performInitialCheck()
        let queue = DispatchQueue.main
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                if !self.connected {
                    self.delegate?.hasConnection()
                }
                self.connected = true
            } else {
                self.connected = false
            }
        }
    
        if (monitor.currentPath.status == .satisfied) {
            self.connected = true
        }
        monitor.start(queue: queue)
    }
    
    
    /// Effectue une vérification du réseau au lancement de l'application
    func performInitialCheck() {
        let monitor = NWPathMonitor()
        let semaphore = DispatchSemaphore(value: 0)
        var initialConnected = false
        let queue = DispatchQueue(label: "NetworkMonitorQueue")
        
        monitor.pathUpdateHandler = { path in
            initialConnected = (path.status == .satisfied)
            semaphore.signal()
        }
        
        monitor.start(queue: queue)
         
        _ = semaphore.wait(timeout: .now() + 0.05)
         monitor.cancel()
        
         self.connected = initialConnected
    }
}
