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
        let isAnimated = component.value != 0.0
        tracks.setTrackAnimated(isAnimated)
    }
}
