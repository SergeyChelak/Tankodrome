//
//  TiledMap+TileSet.swift
//  Tankodrome
//
//  Created by Sergey on 09.03.2025.
//

import Foundation

extension TiledMap {
    struct TileSet: Codable {
        enum CodingKeys: String, CodingKey {
            case firstGid = "firstgid"
            case source
        }
        
        let firstGid: Int
        let source: String
    }
}
