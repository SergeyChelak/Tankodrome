//
//  TileSetData.swift
//  Tankodrome
//
//  Created by Sergey on 09.03.2025.
//

import Foundation
import SpriteKit

enum TileSetDataError: Error {
    case wrongTileSet(String)
}

struct TileSetData {
    typealias TileGroups = [String: SKTileGroup]
    
    let tileSet: SKTileSet
    let groups: TileGroups
    
    static func fromTileSet(named: String) throws -> Self {
        guard let tileSet = SKTileSet(named: named) else {
            throw TileSetDataError.wrongTileSet(named)
        }
        var groups: [String: SKTileGroup] = [:]
        tileSet
            .tileGroups
            .compactMap {
                guard let name = $0.name else {
                    return nil
                }
                return (name, $0)
            }
            .forEach { (name, group) in
                groups[name] = group
            }
        return TileSetData(
            tileSet: tileSet,
            groups: groups
        )
    }
}
