//
//  GameSceneContext.swift
//  Tankodrome
//
//  Created by Sergey on 24.02.2025.
//

import Foundation

protocol GameSceneContext {
    var controllerState: ControllerState { get }
    var deltaTime: TimeInterval { get }
    var sprites: [Sprite] { get }
    func rayCast(from start: CGPoint, rayLength: CGFloat, angle: CGFloat) -> [Sprite]
    func spawn(_ sprite: Sprite)
    func kill(_ sprite: Sprite)
    func popSpecialInstruction() -> SpecialInstruction?
}
