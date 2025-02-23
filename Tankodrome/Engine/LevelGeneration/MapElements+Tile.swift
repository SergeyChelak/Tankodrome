//
//  MapElements+Tile.swift
//  Tankodrome
//
//  Created by Sergey on 24.02.2025.
//

import Foundation

extension MapElements {
    struct Tile: Decodable {
        let name: String
        let group: String
        let connectors: Connectors
        
        struct Connectors: Decodable {
            let up: String
            let right: String
            let down: String
            let left: String
        }
    }
}
