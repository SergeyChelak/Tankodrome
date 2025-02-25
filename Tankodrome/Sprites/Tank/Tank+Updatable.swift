//
//  Tank+Updatable.swift
//  Tankodrome
//
//  Created by Sergey on 25.02.2025.
//

import Foundation

extension Tank: Updatable {
    static let attributeIsAnimated = "isAnimated"
    
    func update() {
        let isAnimated = getAttribute(name: Self.attributeIsAnimated) ?? false
        tracks.setTrackAnimated(isAnimated)
    }
}
