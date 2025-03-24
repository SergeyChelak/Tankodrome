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

struct TileSetRegistry {
    typealias Store = [String: TileSetData]
    private var store: Store = [:]
    
    func distinctTileSet() -> TileSetData? {
        guard let value = store.first?.value,
              store.count == 1 else {
            return nil
        }
        return value
    }
    
    static func from(maps: any Collection<TiledMap>, tileSetMapper: TileSetMapper) throws -> Self {
        var store: Store = [:]
        for map in maps {
            guard let tileSet = map.tileSets.first,
                  let name = tileSetMapper.tileSetName(for: tileSet) else {
                throw GenerateError.tileSetNotSpecified
            }
            if store[name] == nil {
                let data = try TileSetData.fromTileSet(named: name)
                store[name] = data
                print("[OK] Registered '\(name)' tile set")
            }
        }
        return Self(store: store)
    }
}
