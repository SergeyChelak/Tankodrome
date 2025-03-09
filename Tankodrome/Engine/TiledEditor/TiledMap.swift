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
