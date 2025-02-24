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
    let tiles = try prepareTiles(dtoTiles: elements.landscape)
    let wfc = WaveFunctionCollapse()
    wfc.setup(tiles)
}

private func prepareTiles(dtoTiles: [MapElements.Tile]) throws -> [WaveFunctionCollapse.Tile] {
    var tiles: [WaveFunctionCollapse.Tile] = []
    for element in dtoTiles {
        let tile = try WaveFunctionCollapse.Tile.from(dto: element)
        tiles.append(tile)
    }
    updateConstrains(&tiles)
    return tiles
}

private func updateConstrains(_ tiles: inout [WaveFunctionCollapse.Tile]) {
    fatalError()
}

private func load(filename: String, type: String) throws -> MapElements {
    guard let path = Bundle.main.path(forResource: filename, ofType: type) else {
        throw GenerateError.badPath("name: \(filename), type: \(type)")
    }
    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    let decoder = JSONDecoder()
    return try decoder.decode(MapElements.self, from: data)
}
