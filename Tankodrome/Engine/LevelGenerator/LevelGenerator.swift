//
//  LevelGenerator.swift
//  Tankodrome
//
//  Created by Sergey on 24.02.2025.
//

import Foundation
import SpriteKit

class LevelGenerator {
    typealias TileSetRegistry = [String: TileSetData]
    
    // TODO: remove
    private let configuration: Configuration
    
    // TODO: place in constructor
    private let tileSetMapper = TileSetMapper()
    private var tileSetRegistry: TileSetRegistry = [:]
    
    private let waveFunctionCollapse = WaveFunctionCollapse()
    
    init(configuration: Configuration) {
        self.configuration = configuration
    }
    
    func load(_ dataSource: MapsDataSource) throws {
        tileSetRegistry = try tileSetRegistry(from: dataSource.maps.values)
        // TODO: check if map part are the same size
        // TODO: check is tiles are the same size
        try waveFunctionCollapse.setTiles(from: dataSource.maps, mapper: wfcTiledMapper)
    }
    
    private func tileSetRegistry(from maps: any Collection<TiledMap>) throws -> TileSetRegistry {
        var registry: TileSetRegistry = [:]
        for map in maps {
            guard let tileSet = map.tileSets.first,
                  let name = tileSetMapper.tileSetName(for: tileSet) else {
                throw GenerateError.tileSetNotSpecified
            }
            if registry[name] == nil {
                let data = try TileSetData.fromTileSet(named: name)
                registry[name] = data
                print("[OK] Registered '\(name)' tile set")
            }
        }
        return registry
    }
        
    func load() throws  {
        print("[WARN] outdated load function call")
    }
    
    func generateLevel() throws -> Level {
        // TODO: apply random size
        let rows = 50
        let cols = 50
//        let landscape = try generateLandscape(rows: rows, cols: cols)
        let landscape = try stubLandscape(rows: rows, cols: cols)
        let sprites = generateSprites(landscape)
        return Level(
            landscape: landscape,
            sprites: sprites,
            sceneComponents: [
                ScaleComponent(value: 3.0)
            ]
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
        return try fillLandscape(rows: rows, cols: cols, dataSource: waveFunctionCollapse)
    }

    // TODO: remove temporary method
    private func stubLandscape(rows: Int, cols: Int) throws -> Level.Landscape {
        struct DataSource: TileDataSource {
            func tileId(row: Int, col: Int) -> TileId? {
                "Ground_Tile_01_A"
            }
        }
        return try fillLandscape(rows: rows, cols: cols, dataSource: DataSource())
    }
    
    private func fillLandscape(rows: Int, cols: Int, dataSource: TileDataSource) throws -> Level.Landscape {
        // not efficient to get these values each time
        // but it seems to be ok because this action occurs relatively rarely
        let tileSetData = try TileSetData.fromTileSet(named: configuration.tileSetName)
        let tileSize = tileSetData.tileSet.defaultTileSize
        let tileMap = SKTileMapNode(
            tileSet: tileSetData.tileSet,
            columns: cols,
            rows: rows,
            tileSize: tileSize
        )
        tileMap.anchorPoint = .zero
        tileMap.name = "Landscape"
        
        for row in 0..<rows {
            for col in 0..<cols {
                guard let tileId = dataSource.tileId(row: row, col: col),
                      let group = tileSetData.groups[tileId] else {
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

fileprivate func wfcTiledMapper(_ data: (String, TiledMap)) throws -> WaveFunctionCollapse.Tile {
    let properties = data.1.properties
    let property = { (name: String) -> Set<String> in
        var result = Set<String>()
        for entry in properties {
            guard entry.name == name else {
                continue
            }
            result.insert(entry.value)
        }
        return result
    }
    return WaveFunctionCollapse.Tile(
        name: data.0,
        up: property("topEdge"),
        right: property("rightEdge"),
        down: property("bottomEdge"),
        left: property("leftEdge")
    )
}
