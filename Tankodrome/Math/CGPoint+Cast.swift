//
//  CGPoint+Cast.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation

extension CGPoint {
    func vector() -> CGVector {
        CGVector(dx: self.x, dy: self.y)
    }
    
    // not sure if has any sense
    func _size() -> CGSize {
        CGSize(width: self.x, height: self.y)
    }
}
