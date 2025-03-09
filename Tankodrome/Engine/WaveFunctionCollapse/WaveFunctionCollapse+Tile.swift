//
//  WaveFunctionCollapse+Tile.swift
//  Tankodrome
//
//  Created by Sergey on 24.02.2025.
//

import Foundation

extension WaveFunctionCollapse {
    final class Tile {
        typealias Constraint = String
        typealias Options = Set<Constraint>
        let name: TileId
        let up: Options
        let right: Options
        let down: Options
        let left: Options
        
        var upConstraints: Set<TileId> = []
        var rightConstraints: Set<TileId> = []
        var downConstraints: Set<TileId> = []
        var leftConstraints: Set<TileId> = []
        
        init(name: String, up: Options, right: Options, down: Options, left: Options) {
            self.name = name
            self.up = up
            self.right = right
            self.down = down
            self.left = left
        }
    }
}
