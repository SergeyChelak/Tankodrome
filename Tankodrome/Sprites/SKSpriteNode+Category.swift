//
//  SKSpriteNode+Category.swift
//  Tankodrome
//
//  Created by Sergey on 25.02.2025.
//

import Foundation
import SpriteKit

extension SKSpriteNode {
    enum Category: Int {
        case tank = 0
        case border
        case projectile
        case obstacle
        
        var categoryBitMask: UInt32 {
            1 << self.rawValue
        }
    }
}

extension SKPhysicsBody {
    func setCategory(_ category: SKSpriteNode.Category) {
        self.categoryBitMask = category.categoryBitMask
    }
}

