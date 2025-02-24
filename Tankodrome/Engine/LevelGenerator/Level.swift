//
//  Level.swift
//  Tankodrome
//
//  Created by Sergey on 24.02.2025.
//

import Foundation
import SpriteKit

struct Level {
    let landscape: SKTileMapNode
//    let npc: [Sprite]
//    let player: Sprite
}

func generate() throws {
    let elements = try load(filename: "MapElements", type: "json")
    let wfc = WaveFunctionCollapse()
    try wfc.set(dtoTiles: elements.landscape)
}

private func prepareTiles(dtoTiles: [MapElements.Tile]) throws -> [WaveFunctionCollapse.Tile] {
    var tiles: [WaveFunctionCollapse.Tile] = []
    for element in dtoTiles {
        let tile = try WaveFunctionCollapse.Tile.from(dto: element)
        tiles.append(tile)
    }
    updateConstrains(&tiles )
    return tiles
}

private func updateConstrains(_ tiles: inout [WaveFunctionCollapse.Tile]) {
    let isMatch = { (first: WaveFunctionCollapse.Tile.Options, second: WaveFunctionCollapse.Tile.Options) -> Bool in
        !first.intersection(second).isEmpty
    }
    for tile in tiles {
        for other in tiles {
            if isMatch(tile.up, other.down) {
                tile.upConstraints.insert(other.name)
            }
            if isMatch(tile.right, other.left) {
                tile.rightConstraints.insert(other.name)
            }
            if isMatch(tile.down, other.up) {
                tile.downConstraints.insert(other.name)
            }
            if isMatch(tile.left, other.right) {
                tile.leftConstraints.insert(other.name)
            }
        }
    }
}

private func load(filename: String, type: String) throws -> MapElements {
    guard let path = Bundle.main.path(forResource: filename, ofType: type) else {
        throw GenerateError.badPath("name: \(filename), type: \(type)")
    }
    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    let decoder = JSONDecoder()
    return try decoder.decode(MapElements.self, from: data)
}
