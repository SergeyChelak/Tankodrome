//
//  LevelGenerator.swift
//  Tankodrome
//
//  Created by Sergey on 24.02.2025.
//

import Foundation
import SpriteKit

class LevelGenerator {
    typealias NamedGroups = [String: SKTileGroup]    
    
    private let configuration: Configuration
    private let waveFunctionCollapse = WaveFunctionCollapse()
    private var elements: MapElements = .empty
    
    init(configuration: Configuration) {
        self.configuration = configuration
    }
            
    func load() throws  {
        self.elements = try MapElements.from(
            file: configuration.elementsFileName,
            type: configuration.elementsFileType
        )        
        try waveFunctionCollapse.set(dtoTiles: elements.landscape)
    }
    
    func generateLevel() throws -> Level {
        // TODO: apply random size
        let rows = 50
        let cols = 50
        
        let (size, landscape) = try generateLandscape(rows: rows, cols: cols)
        
        return Level(
            size: size,
            landscape: landscape
        )
    }
    
    private func generateLandscape(rows: Int, cols: Int) throws -> (CGSize, SKTileMapNode) {
        waveFunctionCollapse.setSize(rows: rows, cols: cols)
        try waveFunctionCollapse.start()
        // not efficient to get these values each time
        // but it seems to be ok because this action occurs relatively rarely
        let (tileSet, tileGroups) = try tileSetGroups(with: configuration.tileSetName)
        let tileMap = SKTileMapNode(
            tileSet: tileSet,
            columns: cols,
            rows: rows,
            tileSize: tileSet.defaultTileSize
        )
        tileMap.anchorPoint = .zero
        tileMap.name = "Landscape"
        
        for row in 0..<rows {
            for col in 0..<cols {
                guard let tileId = waveFunctionCollapse.tileId(row: row, col: col),
                      let group = tileGroups[tileId] else {
                    continue
                }
                tileMap.setTileGroup(group, forColumn: col, row: row)
            }
        }
        let size = CGSize(width: rows, height: cols) * tileSet.defaultTileSize
        return (size, tileMap)
    }
}


fileprivate extension MapElements {
    static func from(file: String, type: String) throws -> Self {
        guard let path = Bundle.main.path(forResource: file, ofType: type) else {
            throw GenerateError.badPath("name: \(file), type: \(type)")
        }
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data)
    }
}


private func tileSetGroups(with name: String) throws -> (SKTileSet, LevelGenerator.NamedGroups) {
    guard let tileSet = SKTileSet(named: name) else {
        throw GenerateError.wrongTileSet( name)
    }
    var namedGroups: [String: SKTileGroup] = [:]
    tileSet
        .tileGroups
        .compactMap {
            guard let name = $0.name else {
                return nil
            }
            return (name, $0)
        }
        .forEach { (name, group) in
            namedGroups[name] = group
        }
    return (tileSet, namedGroups)
}
