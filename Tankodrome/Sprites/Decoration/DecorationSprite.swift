//
//  DecorationSprite.swift
//  Tankodrome
//
//  Created by Sergey on 23.04.2025.
//

import SpriteKit

class DecorationSprite: SKSpriteNode {
    func setup(
        _ data: LevelData.DecorationData,
        _ converter: BlockPositionConverter) {
        let node = SKSpriteNode(imageNamed: data.decoration.rawValue)
        node.setScale(data.scale)
        node.zRotation = data.rotation
        addChild(node)
        self.position = converter.absolutePoint(data.position)
    }
}
