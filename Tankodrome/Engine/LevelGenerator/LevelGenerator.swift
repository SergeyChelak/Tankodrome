//
//  LevelGenerator.swift
//  Tankodrome
//
//  Created by Sergey on 24.03.2025.
//

import Foundation

final class LevelGenerator {
    private typealias Size = Matrix.Size
    private typealias Position = Matrix.Position
    
    private var mapBlockSize: Size = .zero()
    
    private let waveFunctionCollapse = WaveFunctionCollapse(
        cellCollapsePicker: cellCollapsePicker(_:_:),
        cellConstructor: cellConstructor(index:size:options:)
    )
    
    private let dataSource: MapsDataSource
    private let tileSetMapper: TileSetMapper
    
    init(dataSource: MapsDataSource, tileSetMapper: TileSetMapper) throws {
        self.dataSource = dataSource
        self.tileSetMapper = tileSetMapper
        
        let maps = dataSource.maps.values

        self.mapBlockSize = {
            let sizes = maps
                .map {
                    Size(rows: $0.height, cols: $0.width)
                }
            guard let first = sizes.first,
                  sizes.allSatisfy({ $0 == first }) else {
                print("[WARN] map list is empty or maps have different dimensions")
                // TODO: throw?
                return .zero()
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
        Size(rows: 15, cols: 15)
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
                      let layer = map.landscapeLayer(),
                      let tiles = layer.data else {
                    // TODO:
//                    continue
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

func cellConstructor(index: Int, size: Matrix.Size, options: Set<TileId>) -> WaveFunctionCollapse.Cell {
    let pos = Matrix.Position.from(index: index, of: size)
    let row = pos.row
    let col = pos.col
    let isEdge = row == 0 || col == 0 || row == size.rows - 1 || col == size.cols - 1
    return WaveFunctionCollapse.Cell(
        priority: isEdge ? 1 : 0,
        options: options
    )
}

func cellCollapsePicker(_ context: CellCollapsePickerContext, _ indices: Set<Int>) -> CellCollapse? {
    let size = context.gridSize()
    let edgePositions = indices
        .map {
            Matrix.Position.from(index: $0, of: size)
        }
        .filter {
            let row = $0.row
            let col = $0.col
            return row == 0 || col == 0 || row == size.rows - 1 || col == size.cols - 1
        }
    
    if let position = edgePositions.randomElement() {
        // TODO: create constant storage?
        let solidWall = "A"
        
        let row = position.row
        let col = position.col
                
        let options = context.cell(at: position)
            .options
            .compactMap { (value: String) -> WaveFunctionCollapse.Tile? in
                context.tile(for: value)
            }
            .filter { tile in
                col == 0
                ? tile.left.allSatisfy { $0 == solidWall }
                : true
            }
            .filter { tile in
                col == size.cols - 1
                ? tile.right.allSatisfy { $0 == solidWall }
                : true
            }
            .filter { tile in
                row == 0
                ? tile.up.allSatisfy { $0 == solidWall }
                : true
            }
            .filter { tile in
                row == size.rows - 1
                ? tile.down.allSatisfy { $0 == solidWall }
                : true
            }
        
        if let option = options.randomElement() {
            return (position.index(in: size), option.name)
        }
    }

    return defaultCellCollapsePicker(context, indices)
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
