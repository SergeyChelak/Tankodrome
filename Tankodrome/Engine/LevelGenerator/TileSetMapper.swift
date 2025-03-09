//
//  TileSetMapper.swift
//  Tankodrome
//
//  Created by Sergey on 09.03.2025.
//

import Foundation

protocol TileMapper {
    var name: String { get }    
    func groupName(for id: Int) -> String?
}

final class TileSetMapper {
    private let tileSetSources: [String: TileMapper] = [
        "../Landscape.tsx" : LandscapeTileMapper()
    ]
    
    func tileSetName(for tileSet: TiledMap.TileSet) -> String? {
        tileSetSources[tileSet.source]?.name
    }
    
    func tileGroupName(for tileSet: TiledMap.TileSet, id: Int) -> String? {
        tileSetSources[tileSet.source]?.groupName(for: id)
    }
}

final class LandscapeTileMapper: TileMapper {
    let name = "LandscapeTileSet"
    
    func groupName(for id: Int) -> String? {
        switch id {
        case 1: return "Decor_Tile_B_05"
        case 4: return "Ground_Tile_01_C"
        default:
            print("[WARN] unexpected tile id \(id)")
            return nil
        }
    }
}
