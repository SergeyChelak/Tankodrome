//
//  LevelData.swift
//  Tankodrome
//
//  Created by Sergey on 25.03.2025.
//

import Foundation

struct LevelData {
    typealias LandscapeGrid = Matrix.ArrayWrapper<String>
    protocol Positionable {
        var blockPosition: Matrix.Position { get }
    }
    
    struct ContourObject: Positionable {
        let blockPosition: Matrix.Position
        let rectangle: CGRect
    }
    
    struct BlockPoint: Positionable {
        let blockPosition: Matrix.Position
        let point: CGPoint
    }
    
    struct TankData {
        let spawnPoint: BlockPoint
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
    
    struct DecorationData {
        let decoration: Decoration
        let position: BlockPoint
        let rotation: CGFloat
        let scale: CGFloat
    }
    
    let mapBlockSize: Matrix.Size
    let landscapeGrid: LandscapeGrid
    let contourObjects: [ContourObject]
    let gameActors: [GameActor]
    let decorations: [DecorationData]
    
    static let empty = LevelData(
        mapBlockSize: .zero(),
        landscapeGrid: .empty(),
        contourObjects: [],
        gameActors: [],
        decorations: []
    )
}
