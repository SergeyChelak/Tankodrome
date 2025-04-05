//
//  System.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation

protocol System {
    func levelDidSet(context: GameSceneContext)
    
    func onUpdate(context: GameSceneContext)
    
    func onContact(context: GameSceneContext, collision: Collision)
    
    func onPhysicsSimulated(context: GameSceneContext)
    
    func onFinishUpdate(context: GameSceneContext)
}

extension System {
    func levelDidSet(context: GameSceneContext) {
        // no op
    }
    
    func onUpdate(context: GameSceneContext) {
        // no op
    }
    
    func onContact(context: GameSceneContext, collision: Collision) {
        // no op
    }
    
    func onPhysicsSimulated(context: GameSceneContext) {
        // no op
    }
    
    func onFinishUpdate(context: GameSceneContext) {
        // no op
    }
}


struct Collision {
    let firstBody: Sprite
    let secondBody: Sprite
}
