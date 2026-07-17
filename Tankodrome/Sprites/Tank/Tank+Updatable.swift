//
//  Tank+Updatable.swift
//  Tankodrome
//
//  Created by Sergey on 25.02.2025.
//

import Foundation

extension Tank: Updatable {
    func update() {
        guard let component = getComponent(of: VelocityComponent.self) else {
            return
        }
        // Treat near-zero speed as standing: the AI brakes by decaying velocity
        // (*= 0.9), which never reaches exactly 0, and the track animation must
        // not keep flickering on a tank that is visually standing still.
        let isAnimated = component.value.abs() > 1.0
        tracks.setTrackAnimated(isAnimated)
    }
}
