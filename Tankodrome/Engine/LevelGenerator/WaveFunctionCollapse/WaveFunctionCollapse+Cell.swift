//
//  WaveFunctionCollapse+Cell.swift
//  Tankodrome
//
//  Created by Sergey on 24.02.2025.
//

import Foundation

extension WaveFunctionCollapse {
    struct Cell {
        var options: Set<TileId>
        
        var isCollapsed: Bool {
            entropy == 1
        }
        
        var entropy: Int {
            options.count
        }
    }
}
