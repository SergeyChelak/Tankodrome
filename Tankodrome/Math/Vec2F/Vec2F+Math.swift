//
//  Vec2F+Math.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation

extension Vec2F {
    func squaredDistance(to other: Self) -> CGFloat {
        (self - other).squaredDistance()
    }
    
    func squaredDistance() -> CGFloat {
        self.first.sqr() + self.second.sqr()
    }
    
    func atan2() -> CGFloat {
        Darwin.atan2(second, first)
    }
}
