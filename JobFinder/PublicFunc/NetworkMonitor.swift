//
//  NetworkMonitor.swift
//  Wafid
//
//  Created by almedadsoft on 04/02/2025.
//


import Network
// مراقب حالة الشبكة
class NetworkMonitor {
    static let shared = NetworkMonitor()
    
    var isConnected: Bool = false
    var networkStatusChanged: ((Bool) -> Void)?
    private let monitor = NWPathMonitor()
    
    private init() {
        setupNetworkMonitor()
    }
    
    private func setupNetworkMonitor() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.isConnected = path.status == .satisfied
            DispatchQueue.main.async {
                self?.networkStatusChanged?(self?.isConnected ?? false)
            }
        }
    }
    
    func startMonitoring() {
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }
    
    func stopMonitoring() {
        monitor.cancel()
    }
}

