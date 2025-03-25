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
        let sprites = createSprites()
        let contours = createContours(data, levelRect: landscape.levelRect)
        return Level(
            landscape: landscape,
            sprites: sprites,
            contours: contours,
            sceneComponents: [
                ScaleComponent(value: 3.0)
            ]
        )
    }
    
    private func createLandscape(_ grid: LevelData.LandscapeGrid) -> Level.Landscape {
        let rows = grid.size.rows
        let cols = grid.size.cols
        
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
                let tileId = grid[(row, col)]
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
    
    private func createContours(_ data: LevelData, levelRect: CGRect) -> [SKNode] {
        var nodes: [SKNode] = [
            BorderBuilder(rect: levelRect)
                .addComponent(ObstacleMarker())
                .addComponent(BorderMarker())
                .build()
        ]

        let tileSize = tileSetData.tileSet.defaultTileSize
        let blockSize = data.mapBlockSize.cgSizeValue * tileSize
                
        let contours = data.contourObjects
            .map { (obj: LevelData.ContourObject) -> CGRect in
                let offset = CGPoint(
                    x: blockSize.width * CGFloat(obj.blockPosition.col),
                    y: blockSize.height * CGFloat(obj.blockPosition.row)
                )
                let origin = obj.rectangle.origin + offset
                return CGRect(origin: origin, size: obj.rectangle.size)
            }
            .map {
                RectangleContourBuilder(bodyRectangle: $0)
                    .setYFlipped(true)
                    .setSceneRectangle(levelRect)
                    .addComponent(ObstacleMarker())
                    .addComponent(BorderMarker())
                    .build()
            }
        nodes.append(contentsOf: contours)
        
        return nodes
    }
    
    private func createSprites() -> [Sprite] {
        [
            Tank.Builder
                .random()
                .color(.bronze)
                .addComponent(PlayerMarker())
                .addComponent(ControllerComponent())
                .addComponent(WeaponComponent(model: .heavy))
                .addComponent(HealthComponent(value: 500))
                .addComponent(VelocityComponent(value: 0.0, limit: 1000.0))
                .addComponent(RotationSpeedComponent(value: .pi * 0.9))
                .addComponent(AccelerationComponent(value: 100.0))
                .position(CGPoint(x: 2000, y: 2500))
                .build(),
            
//            Tank.Builder
//                .random()
//                .color(.blue)
//                .addComponent(NpcMarker())
//                .addComponent(WeaponComponent(model: .medium))
//                .addComponent(ControllerComponent())
//                .addComponent(HealthComponent(value: 100))
//                .addComponent(VelocityComponent(value: 0.0, limit: 900.0))
//                .addComponent(RotationSpeedComponent(value: .pi / 3.0))
//                .addComponent(AccelerationComponent(value: 100.0))
//                .position(CGPoint(x: 1500, y: 1500))
//                .build(),
            
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
