//
//  SceneEventPublisher.swift
//  Tankodrome
//
//  Created by Sergey on 04.04.2025.
//

import Combine
import Foundation

/// Bridge from ECS to MVVM
final class SceneEventPublisher {
    enum Event {
        case update, simulatePhysics, finish
    }
    
    private let subject = PassthroughSubject<Event, Never>()
    var publisher: AnyPublisher<Event, Never> {
        subject.eraseToAnyPublisher()
    }
}

extension SceneEventPublisher: SceneEventListener {
    func onUpdate() {
        subject.send(.update)
    }
    
    func onDidSimulatePhysics() {
        subject.send(.simulatePhysics)
    }
    
    func onDidFinishUpdate() {
        subject.send(.finish)
    }
}
