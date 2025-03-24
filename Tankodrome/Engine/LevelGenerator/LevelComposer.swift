//
//  LevelComposer.swift
//  Tankodrome
//
//  Created by Sergey on 25.03.2025.
//

import Foundation
import SpriteKit

// TODO: add protocol
final class LevelComposer {
    private var tileSetData: TileSetData
    
    init(dataSource: MapsDataSource, tileSetMapper: TileSetMapper) throws {
        let maps = dataSource.maps.values
        self.tileSetData = try {
            guard let tileSetData = try TileSetRegistry
                .from(
                    maps: maps,
                    tileSetMapper: tileSetMapper
                )
                .distinctTileSet() else {
                throw GenerateError.multipleOrEmptyTileSet
            }
            return tileSetData
        }()
    }
    
    func level(from data: LevelData) -> Level {
        let landscape = createLandscape(data.landscapeGrid)
        let sprites = createSprites(landscape)
        return Level(
            landscape: landscape,
            sprites: sprites,
            sceneComponents: [
                ScaleComponent(value: 3.0)
            ]
        )
    }
    
    private func createLandscape(_ grid: LevelData.LandscapeGrid) -> Level.Landscape {
        // TODO: so stupid... wrap in matrix
        let rows = grid.count
        let cols = grid[0].count
        
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
                let tileId = grid[row][col]
                guard let group = tileSetData.groups[tileId] else {
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
    
    private func createSprites(_ landscape: Level.Landscape) -> [Sprite] {
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
