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

// TODO: split responsibilities
final class TileSetMapper {
    private let tileSetSources: [String: TileMapper] = [
        "Landscape.tsx" : LandscapeTileMapper()
    ]
    
    func tileSetName(for tileSet: TiledMap.TileSet) -> String? {
        tileSetSources[tileSet.sourceFileName]?.name
    }
    
    func tileGroupName(for tileSet: TiledMap.TileSet, id: Int) -> String? {
        tileSetSources[tileSet.sourceFileName]?.groupName(for: id)
    }
}

final class LandscapeTileMapper: TileMapper {
    let name = "LandscapeTileSet"
    
    func groupName(for id: Int) -> String? {
        switch id {
        case 1: return "Decor_Tile_B_05"
        case 4: return [
            "Ground_Tile_01_C",
            "Ground_Tile_02_C"
        ].randomElement()
        default:
            print("[WARN] unexpected tile id \(id)")
            return nil
        }
    }
}

fileprivate extension TiledMap.TileSet {
    var sourceFileName: String {
        URL(fileURLWithPath: source)
            .lastPathComponent
    }
}
