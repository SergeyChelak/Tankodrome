//
//  Rotation2F.swift
//  Tankodrome
//
//  Created by Sergey on 24.02.2025.
//

import Foundation

protocol Rotation2F: Vec2F {
    static func rotated(radians: CGFloat) -> Self
}

extension Rotation2F {
    static func rotated(radians: CGFloat) -> Self {
        Self.new(cos(radians), sin(radians))
    }
}
