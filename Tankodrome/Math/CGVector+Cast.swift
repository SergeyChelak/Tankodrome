//
//  CGVector+Cast.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation

extension CGVector {
    func point() -> CGPoint {
        CGPoint(x: self.dx, y: self.dy)
    }
    
    func _size() -> CGSize {
        CGSize(width: self.dx, height: self.dy)
    }
}
