//
//  RectangleContourBuilder.swift
//  Tankodrome
//
//  Created by Sergey on 26.03.2025.
//

import Foundation
import SpriteKit

final class RectangleContourBuilder {
    private let bodyRectangle: CGRect
    private var sceneRectangle: CGRect = .zero
    private var components: [Component] = []
    private var yFlipped = false
    
    init(bodyRectangle: CGRect) {
        self.bodyRectangle = bodyRectangle
    }
    
    func setSceneRectangle(_ sceneRectangle: CGRect) -> Self {
        self.sceneRectangle = sceneRectangle
        return self
    }
    
    func setYFlipped(_ flipped: Bool) -> Self {
        self.yFlipped = flipped
        return self
    }
    
    func addComponent(_ component: Component) -> Self {
        components.append(component)
        return self
    }
    
    func build() -> SKSpriteNode {
        let node = SKSpriteNode()
        components.forEach { c in
            node.addComponent(c)
        }
        let rect = destinationRectangle()
        
        node.position = rect.origin
        node.anchorPoint = .zero
        
        let center = CGPoint(
            x: rect.size.width * 0.5,
            y: rect.size.height * 0.5
        )

        let physicsBody = SKPhysicsBody(
            rectangleOf: rect.size,
            center: center
        )
        physicsBody.isDynamic = false
        physicsBody.affectedByGravity = false
        physicsBody.allowsRotation = false
        physicsBody.setCategory(.border)
        node.physicsBody = physicsBody
        return node
    }
    
    private func destinationRectangle() -> CGRect {
        guard yFlipped else {
            return bodyRectangle
        }
        var origin = bodyRectangle.origin
        origin.y = sceneRectangle.size.height - bodyRectangle.origin.y - bodyRectangle.size.height
        return CGRect(
            origin: origin,
            size: bodyRectangle.size
        )
    }
}
