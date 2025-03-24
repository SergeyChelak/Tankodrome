//
//  LevelGenerator.swift
//  Tankodrome
//
//  Created by Sergey on 24.03.2025.
//

import Foundation

func composeLevelGenerator(dataSource: MapsDataSource) throws -> LevelGenerator {
    try LevelGenerator(
        dataSource: dataSource,
        tileSetMapper: TileSetMapper()
    )
}

final class LevelGenerator {
    typealias Size = Matrix.Size
    private var mapBlockSize: Size = .zero
    private var tileSetData: TileSetData
    
    private let waveFunctionCollapse = WaveFunctionCollapse()
    
    init(dataSource: MapsDataSource, tileSetMapper: TileSetMapper) throws {
        let maps = dataSource.maps.values
        
        self.tileSetData = try {
            guard let tileSetData = try TileSetRegistry
                .from(
                    maps: maps,
                    tileSetMapper: tileSetMapper
                )
                    .distinctTileSet() else {
                throw GenerateError.multipleOrEmptyTileSet
            }
            return tileSetData
        }()
        
        self.mapBlockSize = {
            let sizes = maps
                .map {
                    Size(rows: $0.height, cols: $0.width)
                }
            guard let first = sizes.first,
                  sizes.allSatisfy({ $0 == first }) else {
                print("[WARN] map list is empty or maps have different dimensions")
                return .zero
            }
            return first
        }()
                
        try waveFunctionCollapse.setTiles(
            from: dataSource.maps,
            mapper: wfcTiledMapper
        )
    }
        
    
    func generate() throws {
        // amount of map parts, choose as random in 5..10
        let blocksGridSize = { () -> Size in
            Size(rows: 7, cols: 7)
        }()
        
        // generate layout with WFC
        waveFunctionCollapse.setSize(blocksGridSize)
        while true {
            do {
                try waveFunctionCollapse.start(timeout: 1.5)
                break
            } catch GenerateError.timeout {
                print("[WARN] reached timeout")
                continue
            }
        }
        
        for row in 0..<blocksGridSize.rows {
            var s = ""
            for col in 0..<blocksGridSize.cols {
                let id = waveFunctionCollapse.tileId(row: row, col: col)!
                s = s + id + " "
            }
            print(s)
        }
        
        // build level model
        // - fill landscape from block tiles
        // - add physics bodies layer
        // - calculate spawn points
        // - setup player & NPCs
    }
    
    /*
        private func createTileMap(rows: Int, cols: Int) throws -> SKTileMapNode {
            guard let tileSetData else {
                throw GenerateError.unexpectedError("Missing tile set")
            }
            let tileSize = tileSetData.tileSet.defaultTileSize
            let mapSize = Size(
                rows: rows * mapBlockSize.rows,
                cols: cols * mapBlockSize.cols
            )
            let tileMap = SKTileMapNode(
                tileSet: tileSetData.tileSet,
                columns: mapSize.cols,
                rows: mapSize.rows,
                tileSize: tileSize
            )
            tileMap.anchorPoint = .zero
            tileMap.name = "Landscape"
            for row in 0..<mapSize.rows {
                for col in 0..<mapSize.cols {
                    let blockRow = row / mapBlockSize.rows
                    let blockCol = col / mapBlockSize.cols
                    
                    let innerRow = row % mapBlockSize.rows
                    let innerCol = col % mapBlockSize.cols
                    
                    // Important: SpriteKit zero is a bottom left corner & moves up and right
    //                tileMap.setTileGroup(group, forColumn: col, row: mapSize.rows - row - 1)
                }
            }
            fatalError()
        }
    */

}

fileprivate func wfcTiledMapper(_ data: (String, TiledMap)) throws -> WaveFunctionCollapse.Tile {
    let properties = data.1.properties
    let property = { (name: String) -> Set<String> in
        var result = Set<String>()
        for entry in properties {
            guard entry.name == name else {
                continue
            }
            result.insert(entry.value)
        }
        return result
    }
    return WaveFunctionCollapse.Tile(
        name: data.0,
        up: property("topEdge"),
        right: property("rightEdge"),
        down: property("bottomEdge"),
        left: property("leftEdge")
    )
}
