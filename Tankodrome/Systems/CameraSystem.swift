//
//  CameraSystem.swift
//  Tankodrome
//
//  Created by Sergey on 08.04.2025.
//

import Foundation

final class CameraSystem: System {
    func levelDidSet(context: GameSceneContext) {
        guard let camera = context.camera else {
            return
        }
        let mapScaleFactor = camera.getComponent(of: ScaleComponent.self)?.value ?? 1.0
        camera.setScale(mapScaleFactor)
        alignCamera(context: context)
    }
    
    func onFinishUpdate(context: GameSceneContext) {
        alignCamera(context: context)
    }

    /// align camera position with a player
    private func alignCamera(context: GameSceneContext) {
        guard let camera = context.camera,
              let levelRect = camera.getComponent(of: LevelBoundsComponent.self)?.value,
              let playerComponent = context.sprites.first(where: { $0.hasComponent(of: PlayerMarker.self) }) else {
            return
        }
        let position = playerComponent.position
        let mapScaleFactor = camera.getComponent(of: ScaleComponent.self)?.value ?? 1.0
        let size = context.size
        
        var x = position.x
        x = max(x, mapScaleFactor * size.width * 0.5)
        x = min(x, levelRect.width - mapScaleFactor * size.width * 0.5)
        
        var y = position.y
        y = max(y, mapScaleFactor * size.height * 0.5)
        y = min(y, levelRect.height - mapScaleFactor * size.height * 0.5)
        let cameraPosition = CGPoint(x: x, y: y)
        camera.position = cameraPosition
    }

}
