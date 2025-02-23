//
//  Vec2F+Math.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation

extension Vec2F {
    public func squaredDistance(to other: Self) -> CGFloat {
        (self - other).squaredDistance()
    }
    
    public func squaredDistance() -> CGFloat {
        self.first.sqr() + self.second.sqr()
    }
    
    public func atan2() -> CGFloat {
        Darwin.atan2(second, first)
    }
}
