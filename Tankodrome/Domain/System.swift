//
//  System.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation

protocol System {
    func onUpdate(context: GameSceneContext)
    
    func onContact(context: GameSceneContext, collision: Collision)
    
    func onPhysicsSimulated(context: GameSceneContext)
}

struct Collision {
    let firstBody: Sprite
    let secondBody: Sprite
}
