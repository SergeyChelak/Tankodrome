//
//  CGVector+Vec2F.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation

extension CGVector: Vec2F {
    var first: CGFloat {
        get { dx }
        set {
            self.dx = newValue
        }
    }
    
    var second: CGFloat {
        get { dy }
        set {
            self.dy = newValue
        }
    }
    
    static func new(_ first: CGFloat, _ second: CGFloat) -> CGVector {
        Self(dx: first, dy: second)
    }
}

extension CGVector: Rotation2F { }
