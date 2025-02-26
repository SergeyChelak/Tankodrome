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
        let landscape = try generateLandscape(rows: rows, cols: cols)
        let sprites = generateSprites(landscape)
        return Level(
            landscape: landscape,
            sprites: sprites
        )
    }
    
    private func generateLandscape(rows: Int, cols: Int) throws -> Level.Landscape {
        waveFunctionCollapse.setSize(rows: rows, cols: cols)
        while true {
            do {
                try waveFunctionCollapse.start(timeout: 1.5)
                break
            } catch GenerateError.timeout {
                continue
            }
        }
        // not efficient to get these values each time
        // but it seems to be ok because this action occurs relatively rarely
        let (tileSet, tileGroups) = try tileSetGroups(with: configuration.tileSetName)
        let tileSize = tileSet.defaultTileSize
        let tileMap = SKTileMapNode(
            tileSet: tileSet,
            columns: cols,
            rows: rows,
            tileSize: tileSize
        )
        tileMap.anchorPoint = .zero
        tileMap.name = "Landscape"
        
        for row in 0..<rows {
            for col in 0..<cols {
                guard let tileId = waveFunctionCollapse.tileId(row: row, col: col),
                      let group = tileGroups[tileId] else {
                    continue
                }
                // Important: SpriteKit zero is a bottom left corner & moves up and right
                tileMap.setTileGroup(group, forColumn: col, row: rows - row - 1)
            }
        }
        return Level.Landscape(
            tileMap: tileMap,
            tileSize: tileSize,
            rows: rows,
            cols: cols
        )
    }
    
    private func generateSprites(_ landscape: Level.Landscape) -> [Sprite] {
        [
            BorderBuilder(rect: landscape.levelRect)
                .addComponent(ObstacleMarker())
                .addComponent(BorderMarker())
                .build(),
            
            Tank.Builder
                .random()
                .color(.bronze)
                .addComponent(PlayerMarker())
                .addComponent(ControllerComponent())
                .addComponent(WeaponComponent(model: .heavy))
                .addComponent(HealthComponent(value: 500))
                .addComponent(VelocityComponent(value: 0.0, limit: 1000.0))
                .addComponent(RotationSpeedComponent(value: .pi / 3.0))
                .addComponent(AccelerationComponent(value: 100.0))
                .position(CGPoint(x: 1300, y: 1300))
                .build(),
            
            Tank.Builder
                .random()
                .color(.blue)
                .addComponent(NpcMarker())
                .addComponent(WeaponComponent(model: .medium))
                .addComponent(ControllerComponent())
                .addComponent(HealthComponent(value: 100))
                .addComponent(VelocityComponent(value: 0.0, limit: 900.0))
                .addComponent(RotationSpeedComponent(value: .pi / 3.0))
                .addComponent(AccelerationComponent(value: 100.0))
                .position(CGPoint(x: 1500, y: 1500))
                .build(),
            
            Tank.Builder
                .random()
                .color(.yellow)
                .addComponent(NpcMarker())
                .addComponent(WeaponComponent(model: .medium))
                .addComponent(ControllerComponent())
                .addComponent(HealthComponent(value: 100))
                .addComponent(VelocityComponent(value: 0.0, limit: 900.0))
                .addComponent(RotationSpeedComponent(value: .pi / 3.0))
                .addComponent(AccelerationComponent(value: 100.0))
                .position(CGPoint(x: 1500, y: 1100))
                .build()
        ]
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
