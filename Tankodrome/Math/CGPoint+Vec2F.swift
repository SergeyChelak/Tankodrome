//
//  CGPoint+Vec2F.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation

extension CGPoint: Vec2F {
    var first: CGFloat {
        get { x }
        set { self.x = newValue }
    }
    
    var second: CGFloat {
        get { y }
        set { self.y = newValue }
    }
    
    static func new(_ first: CGFloat, _ second: CGFloat) -> Self {
        Self(x: first, y: second)
    }
}
