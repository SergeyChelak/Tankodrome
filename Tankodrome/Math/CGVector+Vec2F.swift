//
//  CGVector+Vec2F.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation

extension CGVector: Vec2F {
    public var first: CGFloat {
        get { dx }
        set {
            self.dx = newValue
        }
    }
    
    public var second: CGFloat {
        get { dy }
        set {
            self.dy = newValue
        }
    }
    
    public static func new(_ first: CGFloat, _ second: CGFloat) -> CGVector {
        Self(dx: first, dy: second)
    }
}
