//
//  WaveFunctionCollapse+Size.swift
//  Tankodrome
//
//  Created by Sergey on 24.02.2025.
//

import Foundation

extension WaveFunctionCollapse {
    struct Size {
        let rows: Int
        let cols: Int
        
        var count: Int {
            rows * cols
        }
        
        static let zero = Self(rows: 0, cols: 0)
    }
}
