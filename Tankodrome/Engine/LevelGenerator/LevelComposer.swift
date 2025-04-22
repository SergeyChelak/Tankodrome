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
        let decorations = createDecorations(data, levelRect: landscape.levelRect)
        return Level(
            landscape: landscape,
            sprites: sprites,
            contours: contours,
            sceneComponents: [],
            camera: createCamera(landscape.levelRect),
            decorations: decorations
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
        let converter = BlockPositionConverter(
            levelData: data,
            levelRect: levelRect,
            tileSize: tileSize
        )
        let contours = data.contourObjects
            .map {
                converter.absoluteRectangle($0)
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
    
    private func createDecorations(_ data: LevelData, levelRect: CGRect) -> [Sprite] {
        let converter = BlockPositionConverter(
            levelData: data,
            levelRect: levelRect,
            tileSize: tileSize
        )
        
        let buildDecoration = { (decorationData: LevelData.DecorationData) -> Sprite in
            let sprite = DecorationSprite()
            sprite.setup(decorationData, converter)
            return sprite
        }
        
        return data.decorations
            .map(buildDecoration)
    }
    
    private func createSprites(_ data: LevelData, levelRect: CGRect) -> [Sprite] {
        let converter = BlockPositionConverter(
            levelData: data,
            levelRect: levelRect,
            tileSize: tileSize
        )
        
        let buildTank = { (tankData: LevelData.TankData, isNPC: Bool) -> Tank in
            Tank.Builder
                .random()
                .color(tankData.color)
                .phase(tankData.phase)
                .addComponent(isNPC ? NpcMarker() : PlayerMarker())
                .addComponent(ControllerComponent())
                .addComponent(WeaponComponent(model: tankData.weapon))
                .addComponent(HealthComponent(value: tankData.health))
                .addComponent(VelocityComponent(value: 0.0, limit: tankData.velocity))
                .addComponent(RotationSpeedComponent(value: tankData.rotationSpeed))
                .addComponent(AccelerationComponent(value: tankData.acceleration))
                .position(converter.absolutePoint(tankData.spawnPoint))
                .build()
        }
        
        var sprites: [Sprite] = []
        for value in data.gameActors {
            let sprite = switch value {
            case .player(let data):
                buildTank(data, false)
            case .npcTank(let data):
                buildTank(data, true)
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
