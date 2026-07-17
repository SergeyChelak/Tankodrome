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
    /// Returns the closest sprite (with a physics body) intersected by the segment
    /// `start`→`end`, ignoring `excluding` (e.g. the querying tank itself).
    /// Use for line-of-sight and clear-shot checks.
    func nearestHit(from start: CGPoint, to end: CGPoint, excluding: Sprite?) -> Sprite?
    func spawn(_ sprite: Sprite)
    func kill(_ sprite: Sprite)
    var specialInstruction: SpecialInstruction? { get }
    func addComponent<T: Component>(_ component: T)
    func getComponent<T: Component>(of type: T.Type) -> T?
    func removeComponent<T: Component>(of type: T.Type)
}
