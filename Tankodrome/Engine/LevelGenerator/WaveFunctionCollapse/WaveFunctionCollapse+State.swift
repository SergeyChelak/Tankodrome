//
//  WaveFunctionCollapse+State.swift
//  Tankodrome
//
//  Created by Sergey on 24.02.2025.
//

import Foundation

extension WaveFunctionCollapse {
    typealias Grid = [Cell]
    
    struct State {
        let grid: Grid
        let fittestCellIndices: Set<Int>
    }
    
    enum Mode {
        case normal, backtrack
    }
}
