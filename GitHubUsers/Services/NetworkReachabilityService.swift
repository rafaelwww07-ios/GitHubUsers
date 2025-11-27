//
//  NetworkReachabilityService.swift
//  GitHubUsers
//
//  Created by Rafael Mukhametov on 24.11.2025.
//

import Foundation
import Network
import Combine

/// Протокол для проверки доступности сети
protocol NetworkReachabilityServiceProtocol: ObservableObject {
    var isConnected: Bool { get }
    var connectionPublisher: AnyPublisher<Bool, Never> { get }
}

/// Сервис для проверки доступности сети
class NetworkReachabilityService: NetworkReachabilityServiceProtocol {
    static let shared = NetworkReachabilityService()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    private let connectionSubject = CurrentValueSubject<Bool, Never>(true)
    private var cancellables = Set<AnyCancellable>()
    
    @Published var isConnected: Bool = true
    
    var connectionPublisher: AnyPublisher<Bool, Never> {
        connectionSubject.eraseToAnyPublisher()
    }
    
    private init() {
        // Подписываемся на изменения и обновляем @Published свойство
        connectionSubject
            .receive(on: DispatchQueue.main)
            .assign(to: &$isConnected)
        
        monitor.pathUpdateHandler = { [weak self] path in
            let isConnected = path.status == .satisfied
            DispatchQueue.main.async {
                self?.connectionSubject.send(isConnected)
            }
        }
        monitor.start(queue: queue)
        
        // Устанавливаем начальное значение
        connectionSubject.send(monitor.currentPath.status == .satisfied)
    }
}

