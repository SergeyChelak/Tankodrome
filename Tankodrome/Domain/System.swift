//
//  System.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation

protocol System {
    func update(context: SceneContext)
}

protocol SceneContext {
    var deltaTime: TimeInterval { get }
    var sprites: [Sprite] { get }
}
