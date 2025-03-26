//
//  BorderBuilder.swift
//  Tankodrome
//
//  Created by Sergey on 26.02.2025.
//

import Foundation
import SpriteKit

final class BorderBuilder {
    private let rect: CGRect
    private var padding: CGFloat = 100.0
    private var components: [Component] = []
    
    init(rect: CGRect) {
        self.rect = rect
    }
    
    func borderWidth(_ padding: CGFloat) -> Self {
        self.padding = padding
        return self
    }
    
    func addComponent(_ component: Component) -> Self {
        components.append(component)
        return self
    }
    
    func build() -> SKSpriteNode {
        let nodes = rectangles()
            .map {
                node(for: $0)
            }
        let sprite = SKSpriteNode()
        sprite.addChildren(nodes)
        return sprite
    }
    
    private func rectangles() -> [CGRect] {
        [
            // left
            CGRect(
                origin: rect.origin - CGPoint(x: padding, y: padding),
                size: CGSize(width: padding, height: rect.height + 2 * padding)
            ),
            // right
            CGRect(
                origin: rect.origin + CGPoint(x: rect.width, y: -padding),
                size: CGSize(width: padding, height: rect.height + 2 * padding)
            ),
            // bottom
            CGRect(
                origin: rect.origin - CGPoint(x: 0, y: padding),
                size: CGSize(width: rect.width, height: padding)
            ),
            // top
            CGRect(
                origin: rect.origin + CGPoint(x: 0, y: rect.height),
                size: CGSize(width: rect.width, height: padding)
            )
        ]
    }
    
    private func node(for rect: CGRect) -> SKSpriteNode {
        let node = SKSpriteNode()
        components.forEach { c in
            node.addComponent(c)
        }
        node.size = rect.size
        let physicsBody = SKPhysicsBody(
            rectangleOf: rect.size,
            center: CGPoint(x: rect.midX, y: rect.midY)
        )
        physicsBody.isDynamic = false
        physicsBody.affectedByGravity = false
        physicsBody.allowsRotation = false
        physicsBody.setCategory(.border)
        node.physicsBody = physicsBody
        return node
    }
}
