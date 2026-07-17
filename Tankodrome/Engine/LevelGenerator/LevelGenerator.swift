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
        cellConstructor: cellConstructor(index:size:options:tileMap:)
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
        let spawnPoints = collectPoints(source: waveFunctionCollapse) { $0.spawnPointsLayer() }
        let decorationPoints = collectPoints(source: waveFunctionCollapse) { $0.decorationsLayer() }
        return LevelData(
            mapBlockSize: mapBlockSize,
            landscapeGrid: landscapeGrid,
            contourObjects: contourObjects,
            gameActors: setupActors(spawnPoints),
            decorations: setupDecorations(decorationPoints)
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
    
    private func collectPoints(
        source: TileDataSource,
        layerExtractor: @escaping (TiledMap) -> TiledMap.Layer?
    ) -> [LevelData.BlockPoint] {
        let blockSize = source.size
        var spawnPoints: [LevelData.BlockPoint] = []
        for row in 0..<blockSize.rows {
            for col in 0..<blockSize.cols {
                guard let id = source.tileId(row: row, col: col),
                      let map = dataSource.maps[id],
                      let layer = layerExtractor(map),
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
                        LevelData.BlockPoint(
                            blockPosition: blockPosition,
                            point: $0
                        )
                    }
                spawnPoints.append(contentsOf: points)
            }
        }
        return spawnPoints
    }
    
    private func setupActors(_ points: [LevelData.BlockPoint]) -> [LevelData.GameActor] {
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
    
    private func setupDecorations(_ points: [LevelData.BlockPoint]) -> [LevelData.DecorationData] {
        let indices = (0..<points.count)
                .map { $0 }
                .shuffled()
        let quantity = indices.count / 3
        return indices[...quantity]
            .map { points[$0] }
            .map(createDecoration)
    }
}

// TODO: create constant storage?
private let solidWall: TileId = "A"

private func isPerimeter(_ position: Matrix.Position, in size: Matrix.Size) -> Bool {
    position.row == 0
    || position.col == 0
    || position.row == size.rows - 1
    || position.col == size.cols - 1
}

/// A perimeter tile must present a solid wall on every edge that faces outside
/// the grid, otherwise actors could move out of the game scene. Interior tiles
/// are always allowed.
private func fitsPerimeter(
    _ tile: WaveFunctionCollapse.Tile,
    at position: Matrix.Position,
    in size: Matrix.Size
) -> Bool {
    let isSolid = { (edge: WaveFunctionCollapse.Tile.Options) in
        edge.allSatisfy { $0 == solidWall }
    }
    if position.col == 0, !isSolid(tile.left) { return false }
    if position.col == size.cols - 1, !isSolid(tile.right) { return false }
    if position.row == 0, !isSolid(tile.up) { return false }
    if position.row == size.rows - 1, !isSolid(tile.down) { return false }
    return true
}

func cellConstructor(
    index: Int,
    size: Matrix.Size,
    options: Set<TileId>,
    tileMap: [TileId: WaveFunctionCollapse.Tile]
) -> WaveFunctionCollapse.Cell {
    let position = Matrix.Position.from(index: index, of: size)
    guard isPerimeter(position, in: size) else {
        return WaveFunctionCollapse.Cell(priority: 0, options: options)
    }
    // Constrain perimeter cells up front so they can *only* ever collapse to a
    // wall-facing tile. Propagation only removes options, so this guarantee
    // holds regardless of collapse order, propagation or backtracking.
    let walls = options.filter { id in
        guard let tile = tileMap[id] else { return false }
        return fitsPerimeter(tile, at: position, in: size)
    }
    return WaveFunctionCollapse.Cell(priority: 1, options: walls)
}

func cellCollapsePicker(_ context: CellCollapsePickerContext, _ indices: Set<Int>) -> CellCollapse? {
    let size = context.gridSize()
    let edgePositions = indices
        .map {
            Matrix.Position.from(index: $0, of: size)
        }
        .filter {
            isPerimeter($0, in: size)
        }

    if let position = edgePositions.randomElement() {
        let options = context.cell(at: position)
            .options
            .compactMap { (value: String) -> WaveFunctionCollapse.Tile? in
                context.tile(for: value)
            }
            .filter { tile in
                fitsPerimeter(tile, at: position, in: size)
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

fileprivate func createActorPlayer(_ point: LevelData.BlockPoint) -> LevelData.GameActor {
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

fileprivate func createActorNPC(_ point: LevelData.BlockPoint) -> LevelData.GameActor {
    let data = LevelData.TankData(
        spawnPoint: point,
        phase: randomAngle(),
        color: .blue,
        weapon: .medium,
        health: 100,
        velocity: 900.0,
        acceleration: 100.0,
        rotationSpeed: .pi * 0.5
    )
    return .npcTank(data)
}

fileprivate func createDecoration(_ position: LevelData.BlockPoint) -> LevelData.DecorationData {
    let decorations = Decoration.allCases
    let decoration = decorations.randomElement() ?? decorations[0]
    return .init(
        decoration: decoration,
        position: position,
        rotation: randomAngle(),
        scale: 1.0
    )
}

private func randomAngle() -> CGFloat {
    .random(in: 0..<360).degreesToRadians()
}
