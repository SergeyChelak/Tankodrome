//
//  TiledMap+Property.swift
//  Tankodrome
//
//  Created by Sergey on 09.03.2025.
//

import Foundation

extension TiledMap {
    struct Property: Codable {
        let name: String
        let type: String
        let value: String
    }
}
