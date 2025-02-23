//
//  SKNode+Children.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation
import SpriteKit

extension SKNode {
    func addChildren(_ nodes: SKNode...) {
        nodes.forEach { addChild($0) }
    }
    
    func addChildren(_ nodes: [SKNode]) {
        nodes.forEach { addChild($0) }
    }
}
