//
//  Network.swift
//  Charivari
//
//  Created by William Leroux on 2024-11-28.
//

import SwiftUI
import Network
class NetworkMonitor : ObservableObject{
    
    static let shared = NetworkMonitor()
    
    private let monitor = NWPathMonitor()
    @Published var connected = false
    weak var delegate: NetworkDelegate?
    
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
    
    func performInitialCheck() {
        let monitor = NWPathMonitor()
        let semaphore = DispatchSemaphore(value: 0)
        var initialConnected = false
        let queue = DispatchQueue.global(qos: .background)
        
        monitor.pathUpdateHandler = { path in
            initialConnected = (path.status == .satisfied)
            semaphore.signal()
        }
        
        monitor.start(queue: queue)
         
        _ = semaphore.wait(timeout: .now() + 0.05)
         monitor.cancel()
        
         self.connected = initialConnected
    }
    
    /// Retrieves the current network state.
    ///
    /// - Returns: A boolean value indicating the network state (connected or not).
    func getNetworkState() -> Bool {
        return connected
    }
}
