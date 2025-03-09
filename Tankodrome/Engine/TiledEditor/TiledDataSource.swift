//
//  TiledDataSource.swift
//  Tankodrome
//
//  Created by Sergey on 09.03.2025.
//

import Foundation

protocol MapsDataSource {
    var maps: [String: TiledMap] { get }
    
//    func load() throws
}

class TiledDataSource: MapsDataSource {
    private let partFiles = [
        "Part_A",
        "Part_B",
        "Part_C",
        "Part_D",
        "Part_E",
        "Part_F",
        "Part_G",
        "Part_H",
        "Part_I",
        "Part_J",
        "Part_K",
        "Part_L",
    ]
    
    private(set) var maps: [String: TiledMap] = [:]
    
    func load() throws {
        maps.removeAll()
        for name in partFiles {
            let map = try TiledMap.from(file: name)
            maps[name] = map
        }
    }
}
