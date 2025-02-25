//
//  Level.swift
//  Tankodrome
//
//  Created by Sergey on 24.02.2025.
//

import Foundation
import SpriteKit

struct Level {
    let landscape: Landscape
//    let npc: [Sprite]
//    let player: Sprite
    
    struct Landscape {
        let tileMap: SKTileMapNode
        let tileSize: CGSize
        let rows: Int
        let cols: Int
        
        var levelSize: CGSize {
            CGSize(width: cols, height: rows) * tileSize
        }
    }
}

