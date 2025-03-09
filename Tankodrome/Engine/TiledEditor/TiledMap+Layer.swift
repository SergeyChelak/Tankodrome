//
//  TiledMap+Layer.swift
//  Tankodrome
//
//  Created by Sergey on 09.03.2025.
//

import Foundation

extension TiledMap {
    struct Layer: Codable {
        let id: Int
        let name: String
        let type: LayerType
        let height: Int?
        let width: Int?
        let data: [Int]?
        let objects: [LevelObject]?
    }
    
    enum LayerType: String, Codable {
        case objectGroup = "objectgroup"
        case tileLayer = "tilelayer"
    }

    struct LevelObject: Codable {
        private enum CodingKeys: String, CodingKey {
            case id
            case type
            case height
            case width
            case x, y
            case isPoint = "point"
        }
        
        let id: Int
        let height: CGFloat
        let width: CGFloat
        let type: String
        let x: CGFloat
        let y: CGFloat
        let isPoint: Bool?
        // TODO: ...
    }
}
