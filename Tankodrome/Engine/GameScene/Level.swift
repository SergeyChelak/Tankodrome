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
    let sprites: [Sprite]
    let sceneComponents: [Component]
    
    struct Landscape {
        let tileMap: SKTileMapNode
        let tileSize: CGSize
        let rows: Int
        let cols: Int
        
        var levelSize: CGSize {
            CGSize(width: cols, height: rows) * tileSize
        }
        
        var levelRect: CGRect {
            CGRect(origin: .zero, size: levelSize)
        }
    }
}

struct LevelModel {
    // TODO: refactor
    typealias Size = Matrix.Size
    
    struct Landscape {
        let size: Size
        private var tiles: [String]
        
        init(size: Size) {
            self.size = size
            self.tiles = [String].init(
                repeating: "",
                count: size.count
            )
        }
    }
}
