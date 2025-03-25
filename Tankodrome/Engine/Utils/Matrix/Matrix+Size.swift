//
//  Matrix+Size.swift
//  Tankodrome
//
//  Created by Sergey on 24.03.2025.
//

import Foundation

extension Matrix {
    struct Size: Equatable {
        let rows: Int
        let cols: Int
        
        var count: Int {
            rows * cols
        }
        
        static func zero() -> Self {
            Self(rows: 0, cols: 0)
        }
    }
}

extension Matrix.Size {
    var cgSizeValue: CGSize {
        CGSize(width: self.cols, height: self.rows)
    }
}
