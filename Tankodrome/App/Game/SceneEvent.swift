//
//  SceneEvent.swift
//  Tankodrome
//
//  Created by Sergey on 04.04.2025.
//

import Combine
import Foundation

enum SceneEvent {
    case update, simulatePhysics, finish
}

protocol SceneEventPublisher {
    var publisher: AnyPublisher<SceneEvent, Never> { get }
}
