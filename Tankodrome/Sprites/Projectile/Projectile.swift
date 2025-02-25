//
//  Projectile.swift
//  Tankodrome
//
//  Created by Sergey on 25.02.2025.
//

import Foundation
import SpriteKit

class Projectile: SKSpriteNode {
    func setupAppearance(imageName: String) {
        let node = SKSpriteNode(imageNamed: imageName)
        self.size = node.size
        addChild(node)
    }
    
    func setupPhysics() {
        let physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 20, height: 60))
        physicsBody.affectedByGravity = false
        physicsBody.isDynamic = true
        physicsBody.allowsRotation = false
        physicsBody.setCategory(.projectile)
        // collide with everything
        physicsBody.contactTestBitMask = UInt32.max
        self.physicsBody = physicsBody
    }
}
