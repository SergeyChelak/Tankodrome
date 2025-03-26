//
//  TiledMap.swift
//  Tankodrome
//
//  Created by Sergey on 09.03.2025.
//

import Foundation

struct TiledMap: Codable {
    private enum CodingKeys: String, CodingKey {
        case height
        case width
        case tileHeight = "tileheight"
        case tileWidth = "tilewidth"
        case layers
        case properties
        case tileSets = "tilesets"
    }
    
    let height: Int
    let width: Int
    let tileHeight: Int
    let tileWidth: Int
    let layers: [Layer]
    let properties: [Property]
    let tileSets: [TileSet]
}

extension TiledMap {
    func landscapeLayer() -> Layer? {
        layer(with: "landscape")
    }
    
    func contourObjectsLayer() -> Layer? {
        layer(with: "contour_objects")
    }
    
    func spawnPointsLayer() -> Layer? {
        layer(with: "spawn_points")
    }

    private func layer(with name: String) -> Layer? {
        layers.first {
            $0.name == name
        }
    }
}
