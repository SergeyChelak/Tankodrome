//
//  CGSize+Vec2F.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation

extension CGSize: Vec2F {
    public var first: CGFloat {
        get { width }
        set { self.width = newValue }
    }
    
    public var second: CGFloat {
        get { height }
        set { self.height = newValue }
    }
    
    public static func new(_ first: CGFloat, _ second: CGFloat) -> Self {
        Self(width: first, height: second)
    }
}
