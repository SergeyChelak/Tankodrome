//
//  MapElements.swift
//  Tankodrome
//
//  Created by Sergey on 24.02.2025.
//

import Foundation

struct MapElements: Decodable {
    let landscape: [Tile]
    let objects: [Object]
}
