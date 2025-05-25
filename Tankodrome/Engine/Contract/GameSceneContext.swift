//
//  GameSceneContext.swift
//  Tankodrome
//
//  Created by Sergey on 24.02.2025.
//

import Foundation

protocol GameSceneContext {
    var size: CGSize { get }
    var camera: Camera? { get }
    var inputEvents: [ControlEvent] { get }
    var deltaTime: TimeInterval { get }
    var sprites: [Sprite] { get }
    func rayCast(from start: CGPoint, rayLength: CGFloat, angle: CGFloat) -> [Sprite]
    func spawn(_ sprite: Sprite)
    func kill(_ sprite: Sprite)
    var specialInstruction: SpecialInstruction? { get }
    func addComponent<T: Component>(_ component: T)
    func getComponent<T: Component>(of type: T.Type) -> T?
    func removeComponent<T: Component>(of type: T.Type)
}
