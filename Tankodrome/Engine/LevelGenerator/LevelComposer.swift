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
    
    private var tileSize: CGSize {
        tileSetData.tileSet.defaultTileSize
    }
    
    func level(from data: LevelData) -> Level {
        let landscape = createLandscape(data.landscapeGrid)
        let contours = createContours(data, levelRect: landscape.levelRect)
        let sprites = createSprites(data, levelRect: landscape.levelRect)
        return Level(
            landscape: landscape,
            sprites: sprites,
            contours: contours,
            sceneComponents: [],
            camera: createCamera(landscape.levelRect)
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
    
    private func createSprites(_ data: LevelData, levelRect: CGRect) -> [Sprite] {
        let blockSize = data.mapBlockSize.cgSizeValue * tileSize
        let calculatePosition = { (sp: LevelData.BlockPoint) -> CGPoint in
            let offset = CGPoint(
                x: blockSize.width * CGFloat(sp.blockPosition.col),
                y: blockSize.height * CGFloat(sp.blockPosition.row)
            )
            var result = offset + sp.point
            result.y = levelRect.size.height - result.y
            return result
        }
        var sprites: [Sprite] = []
        for value in data.gameActors {
            let sprite = switch value {
            case .player(let data):
                Tank.Builder
                    .random()
                    .color(data.color)
                    .phase(data.phase)
                    .addComponent(PlayerMarker())
                    .addComponent(ControllerComponent())
                    .addComponent(WeaponComponent(model: data.weapon))
                    .addComponent(HealthComponent(value: data.health))
                    .addComponent(VelocityComponent(value: 0.0, limit: data.velocity))
                    .addComponent(RotationSpeedComponent(value: data.rotationSpeed))
                    .addComponent(AccelerationComponent(value: data.acceleration))
                    .position(calculatePosition(data.spawnPoint))
                    .build()
            case .npcTank(let data):
                Tank.Builder
                    .random()
                    .color(data.color)
                    .phase(data.phase)
                    .addComponent(NpcMarker())
                    .addComponent(ControllerComponent())
                    .addComponent(WeaponComponent(model: data.weapon))
                    .addComponent(HealthComponent(value: data.health))
                    .addComponent(VelocityComponent(value: 0.0, limit: data.velocity))
                    .addComponent(RotationSpeedComponent(value: data.rotationSpeed))
                    .addComponent(AccelerationComponent(value: data.acceleration))
                    .position(calculatePosition(data.spawnPoint))
                    .build()
            }
            sprites.append(sprite)
        }
        
        return sprites
    }
    
    private func createCamera(_ levelRect: CGRect) -> SKCameraNode {
        let camera = SKCameraNode()
        camera.addComponents(
            ScaleComponent(value: 3.0),
            LevelBoundsComponent(value: levelRect)
        )
        return camera
    }
}
