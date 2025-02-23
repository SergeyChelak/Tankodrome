//
//  CGPoint+Vec2F.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation

extension CGPoint: Vec2F {
    public var first: CGFloat {
        get { x }
        set { self.x = newValue }
    }
    
    public var second: CGFloat {
        get { y }
        set { self.y = newValue }
    }
    
    public static func new(_ first: CGFloat, _ second: CGFloat) -> Self {
        Self(x: first, y: second)
    }
}
