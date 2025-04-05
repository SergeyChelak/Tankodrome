//
//  LevelData.swift
//  Tankodrome
//
//  Created by Sergey on 25.03.2025.
//

import Foundation

struct LevelData {
    typealias LandscapeGrid = Matrix.ArrayWrapper<String>
    
    struct ContourObject {
        let blockPosition: Matrix.Position
        let rectangle: CGRect
    }
    
    struct SpawnPoint {
        let blockPosition: Matrix.Position
        let point: CGPoint
    }
    
    struct TankData {
        let spawnPoint: SpawnPoint
        let phase: CGFloat
        let color: Tank.Builder.Color
        let weapon: WeaponModel
        let health: CGFloat
        let velocity: CGFloat
        let acceleration: CGFloat
        let rotationSpeed: CGFloat
    }
    
    enum GameActor {
        case player(TankData)
        case npcTank(TankData)
    }
    
    let mapBlockSize: Matrix.Size
    let landscapeGrid: LandscapeGrid
    let contourObjects: [ContourObject]
    let gameActors: [GameActor]
    
    static let empty = LevelData(
        mapBlockSize: .zero(),
        landscapeGrid: .empty(),
        contourObjects: [],
        gameActors: []
    )
}
