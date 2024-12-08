//
//  NetworkDelegate.swift
//  Charivari
//
//  Created by William Leroux on 2024-12-05.
//

/// Délégué du network
protocol NetworkDelegate: AnyObject {
    
    /// Est appelé lorsque l'appareil a du réseau
    func hasConnection()
}
