//
//  ControllerSystem.swift
//  Tankodrome
//
//  Created by Sergey on 26.02.2025.
//

import GameController
import Foundation

final class ControllerSystem: System {
    func onUpdate(context: any GameSceneContext) {
        /// this function should update sprite parameters according to controller state
        /// currently the movement system is responsible for that
        /// but it makes movement system is limited to move controllable sprites only
    }
        
    func onPhysicsSimulated(context: any GameSceneContext) {
        context
            .sprites
            .compactMap { (sprite: Sprite) -> ControllerComponent? in
                guard sprite.hasComponent(of: PlayerMarker.self) else {
                    return nil
                }
                return sprite.getComponent(of: ControllerComponent.self)
            }
            .forEach {
                for event in context.inputEvents {
                    $0.value.apply(event)
                }
            }
    }
}

fileprivate extension ControllerComponent.State {
    mutating func apply(_ event: ControlEvent) {
        switch event {
        case .key(let keyData):
            apply(keyData)
        case .gamepadDirection(let data):
            apply(data)
        case .gamepadButton(let data):
            apply(data)
        }
    }
    
    mutating func apply(_ data: ControlEvent.KeyData) {
        let update = { (value: inout Bool, codes: Set<GCKeyCode>, keyData: ControlEvent.KeyData) in
            guard codes.contains(keyData.keyCode) else {
                return
            }
            value = data.isPressed
        }
        update(&isAcceleratePressed, [.upArrow, .keyW], data)
        update(&isDeceleratePressed, [.downArrow, .keyS], data)
        update(&isTurnLeftPressed, [.leftArrow, .keyA], data)
        update(&isTurnRightPressed, [.rightArrow, .keyD], data)
        update(&isShootPressed, [.spacebar], data)
    }
    
    mutating func apply(_ data: ControlEvent.GamepadDirectionData) {
        isAcceleratePressed = data.yValue > 0
        isDeceleratePressed = data.yValue < 0
        isTurnLeftPressed = data.xValue < 0
        isTurnRightPressed = data.xValue > 0
    }
    
    mutating func apply(_ data: ControlEvent.GamepadButtonState) {
        isShootPressed = data.button == .b && data.isPressed
    }
}

fileprivate extension Bool {
    static func |= (lhs: inout Bool, rhs: Bool) {
        lhs = lhs || rhs
    }
}
