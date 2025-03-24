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
    private typealias Size = Matrix.Size
    private typealias Position = Matrix.Position
    
    private var mapBlockSize: Size = .zero
    private var tileSetData: TileSetData
    
    private let waveFunctionCollapse = WaveFunctionCollapse()
    
    private let dataSource: MapsDataSource
    private let tileSetMapper: TileSetMapper
    
    init(dataSource: MapsDataSource, tileSetMapper: TileSetMapper) throws {
        self.dataSource = dataSource
        self.tileSetMapper = tileSetMapper
        
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
                // TODO: throw?
                return .zero
            }
            return first
        }()
                
        try waveFunctionCollapse.setTiles(
            from: dataSource.maps,
            mapper: wfcTiledMapper
        )
    }
    
    func generate() throws -> LevelData {
        let blocksSize = generateLevelSize()
        
        // generate layout with WFC
        waveFunctionCollapse.setSize(blocksSize)
        while true {
            do {
                try waveFunctionCollapse.start(timeout: 1.5)
                break
            } catch GenerateError.timeout {
                print("[WARN] reached timeout")
                continue
            }
        }
        
        let landscapeGrid = try fillLandscape(source: waveFunctionCollapse, blockSize: blocksSize)
                
        // build level with steps
        // - fill landscape from block tiles
        // - add physics bodies layer
        // - collect spawn points
        // - setup player & NPCs
        
        return LevelData(
            landscapeGrid: landscapeGrid
        )
    }
    
    private func generateLevelSize() -> Size {
        // amount of map parts, choose as random in 5..10
        Size(rows: 7, cols: 7)
    }
    
    private func fillLandscape(source: TileDataSource, blockSize: Size) throws -> LevelData.LandscapeGrid {
        let gridSize = Size(
            rows: blockSize.rows * mapBlockSize.rows,
            cols: blockSize.cols * mapBlockSize.cols
        )
        
        var landscapeGrid = [[String]].init(
            repeating: [String].init(repeating: "", count: gridSize.cols),
            count: gridSize.rows
        )
        
        for row in 0..<blockSize.rows {
            for col in 0..<blockSize.cols {
                guard let id = waveFunctionCollapse.tileId(row: row, col: col),
                      let map = dataSource.maps[id],
                      let tileSet = map.tileSets.first,
                      let layer = map.layers.first(where: { $0.name == "landscape" }),
                      let tiles = layer.data else {
                    // TODO: continue?
                    throw GenerateError.missingLayer
                }
                for (i, value) in tiles.enumerated() {
                    let innerPosition = Position.from(index: i, of: mapBlockSize)
                    let r = innerPosition.row + row * mapBlockSize.rows
                    let c = innerPosition.col + col * mapBlockSize.cols
                    guard let tile = tileSetMapper.tileGroupName(for: tileSet, id: value) else {
                        throw GenerateError.missingTile
                    }
                    landscapeGrid[r][c] = tile
                }
            }
        }
        
        return landscapeGrid
    }
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
