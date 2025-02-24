//
//  WaveFunctionCollapse+Tile.swift
//  Tankodrome
//
//  Created by Sergey on 24.02.2025.
//

import Foundation

extension WaveFunctionCollapse {
    final class Tile {
        typealias Options = Set<Int>
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

extension WaveFunctionCollapse.Tile {
    static func from(dto: MapElements.Tile) throws -> Self {
        let parse = { (inp: String) throws -> WaveFunctionCollapse.Tile.Options in
            var set: Set<Int> = []
            for val in inp.split(separator: ",") {
                guard let value = Int(val) else {
                    throw GenerateError.invalidConnectorValue(inp)
                }
                set.insert(value)
            }
            return set
        }
        let con = dto.connectors
        return Self(
            name: dto.name,
            up: try parse(con.up),
            right: try parse(con.right),
            down: try parse(con.down),
            left: try parse(con.left)
        )
    }
}
