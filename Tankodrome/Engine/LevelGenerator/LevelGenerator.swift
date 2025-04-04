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
        
        let landscapeGrid = try fillLandscape(source: waveFunctionCollapse)
        let contourObjects = try contours(source: waveFunctionCollapse)
        let spawnPoints = collectSpawnPoints(source: waveFunctionCollapse)
        let actors = setupActors(spawnPoints)
        return LevelData(
            mapBlockSize: mapBlockSize,
            landscapeGrid: landscapeGrid,
            contourObjects: contourObjects,
            gameActors: actors
        )
    }
    
    private func generateLevelSize() -> Size {
        // amount of map parts, choose as random in 5..10
        let dim = 10
        return Size(rows: dim, cols: dim)
    }
    
    private func fillLandscape(source: TileDataSource) throws -> LevelData.LandscapeGrid {
        let blockSize = source.size
        let gridSize = Size(
            rows: blockSize.rows * mapBlockSize.rows,
            cols: blockSize.cols * mapBlockSize.cols
        )
        var landscapeGrid = LevelData.LandscapeGrid(size: gridSize, value: "")
        for row in 0..<blockSize.rows {
            for col in 0..<blockSize.cols {
                guard let id = source.tileId(row: row, col: col),
                      let map = dataSource.maps[id],
                      let tileSet = map.tileSets.first,
                      let layer = map.landscapeLayer(),
                      let tiles = layer.data else {
                    throw GenerateError.missingLayer("landscape")
                }
                for (i, value) in tiles.enumerated() {
                    let innerPosition = Position.from(index: i, of: mapBlockSize)
                    let r = innerPosition.row + row * mapBlockSize.rows
                    let c = innerPosition.col + col * mapBlockSize.cols
                    guard let tile = tileSetMapper.tileGroupName(for: tileSet, id: value) else {
                        throw GenerateError.missingTile
                    }
                    landscapeGrid[(r, c)] = tile
                }
            }
        }
        
        return landscapeGrid
    }
    
    private func contours(source: TileDataSource) throws -> [LevelData.ContourObject] {
        let blockSize = source.size
        var contourObjects: [LevelData.ContourObject] = []
        // only rectangles are supported right now
        for row in 0..<blockSize.rows {
            for col in 0..<blockSize.cols {
                guard let id = source.tileId(row: row, col: col),
                      let map = dataSource.maps[id],
                      let layer = map.contourObjectsLayer(),
                      let objects = layer.objects else {
                    throw GenerateError.missingLayer("contours")
                }
                let blockPosition = Matrix.Position(row: row, col: col)
                let items = objects
                    .filter {
                        $0.isPoint != true
                    }
                    .map {
                        CGRect(x: $0.x, y: $0.y, width: $0.width, height: $0.height)
                    }
                    .map {
                        LevelData.ContourObject(
                            blockPosition: blockPosition,
                            rectangle: $0
                        )
                    }
                contourObjects.append(contentsOf: items)
            }
        }
        return contourObjects
    }
    
    private func collectSpawnPoints(source: TileDataSource) -> [LevelData.SpawnPoint] {
        let blockSize = source.size
        var spawnPoints: [LevelData.SpawnPoint] = []
        for row in 0..<blockSize.rows {
            for col in 0..<blockSize.cols {
                guard let id = source.tileId(row: row, col: col),
                      let map = dataSource.maps[id],
                      let layer = map.spawnPointsLayer(),
                      let objects = layer.objects else {
                    continue
                }
                let blockPosition = Matrix.Position(row: row, col: col)
                let points = objects
                    .map {
                        assert($0.isPoint == true)
                        return CGPoint(x: $0.x, y: $0.y)
                    }
                    .map {
                        LevelData.SpawnPoint(
                            blockPosition: blockPosition,
                            point: $0
                        )
                    }
                spawnPoints.append(contentsOf: points)
            }
        }
        return spawnPoints
    }
    
    private func setupActors(_ points: [LevelData.SpawnPoint]) -> [LevelData.GameActor] {
        let indices = (0..<points.count)
                .map { $0 }
                .shuffled()
        var actors: [LevelData.GameActor] = []
        // setup player position
        let point = points[indices[0]]
        let val = createActorPlayer(point)
        actors.append(val)
        // setup npc position
        let npcCount = points.count / 3
        for index in indices[1...npcCount] {
            let point = points[index]
            let val = createActorNPC(point)
            actors.append(val)
        }
        return actors
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

fileprivate func createActorPlayer(_ point: LevelData.SpawnPoint) -> LevelData.GameActor {
    let data = LevelData.TankData(
        spawnPoint: point,
        phase: .random(in: 0..<360).degreesToRadians(),
        color: .bronze,
        weapon: .medium,
        health: 5000.0, //.greatestFiniteMagnitude,
        velocity: 1000.0,
        acceleration: 100.0,
        rotationSpeed: .pi * 0.8
    )
    return .player(data)
}

fileprivate func createActorNPC(_ point: LevelData.SpawnPoint) -> LevelData.GameActor {
    let data = LevelData.TankData(
        spawnPoint: point,
        phase: .random(in: 0..<360).degreesToRadians(),
        color: .blue,
        weapon: .medium,
        health: 100,
        velocity: 900.0,
        acceleration: 100.0,
        rotationSpeed: .pi * 0.5
    )
    return .npcTank(data)
}
