//
//  WaveFunctionCollapse.swift
//  Tankodrome
//
//  Created by Sergey on 24.02.2025.
//

import Foundation
import DequeModule

// TODO: review -- it could be nested alias in WFC
typealias TileId = String

final class WaveFunctionCollapse {
    typealias TileIdSet = Set<TileId>
    typealias Size = Matrix.Size
    typealias Position = Matrix.Position
    
    typealias CellCollapsePicker = (CellCollapsePickerContext, Set<Int>) -> CellCollapse?
    typealias CellConstructor = (Int, Size, Set<TileId>) -> Cell
    
    private(set) var size: Size = .zero()
    private var grid: Grid = .empty()
    private var tileMap: [TileId: Tile] = [:]
    
    private var cellCollapsePicker: CellCollapsePicker
    private var cellConstructor: CellConstructor
    
    init(
        cellCollapsePicker: @escaping CellCollapsePicker = defaultCellCollapsePicker,
        cellConstructor: @escaping CellConstructor = defaultCellConstructor
    ) {
        self.cellCollapsePicker = cellCollapsePicker
        self.cellConstructor = cellConstructor
    }
    
    // MARK: setup
    func setSize(rows: Int, cols: Int) {
        self.setSize(Size(rows: rows, cols: cols))
    }
    
    func setSize(_ size: Size) {
        self.size = size
    }
    
    func setTiles<T>(from input: any Collection<T>, mapper: (T) throws -> Tile) throws {
        var tiles: [Tile] = []
        for element in input {
            let tile = try mapper(element)
            tiles.append(tile)
        }
        updateConstrains(&tiles)
        
        let sequence = tiles
            .map {
                ($0.name, $0)
            }
        self.tileMap = Dictionary(uniqueKeysWithValues: sequence)
    }
    
    private func updateConstrains(_ tiles: inout [Tile]) {
        let isMatch = { (first: Tile.Options, second: Tile.Options) -> Bool in
            !first.intersection(second).isEmpty
        }
        for tile in tiles {
            for other in tiles {
                if isMatch(tile.up, other.down) {
                    tile.upConstraints.insert(other.name)
                }
                if isMatch(tile.right, other.left) {
                    tile.rightConstraints.insert(other.name)
                }
                if isMatch(tile.down, other.up) {
                    tile.downConstraints.insert(other.name)
                }
                if isMatch(tile.left, other.right) {
                    tile.leftConstraints.insert(other.name)
                }
            }
        }
    }
    
    private func makeGrid() -> Grid {
        let options = Set(tileMap.keys)
        let array = (0..<size.count)
            .map { index in
                cellConstructor(index, size, options)
            }
        return Grid(content: array, size: size)
    }
    
    // MARK: Wfc
    func start(timeout: TimeInterval) throws {
        self.grid = makeGrid()
        let startTime = Date()
        let duration = { () -> TimeInterval in
            Date().timeIntervalSince(startTime)
        }
        var states: [State] = []
        var mode: Mode = .normal
        while true {
            var indices: Set<Int>
            switch mode {
            case .normal:
                indices = getFittestCellIndices()
            case .backtrack:
                guard let state = states.popLast() else {
                    throw GenerateError.invalidState
                }
                guard !state.fittestCellIndices.isEmpty else {
                    continue
                }
                self.grid = state.grid
                indices = state.fittestCellIndices
                mode = .normal
            }
            
            guard let (index, option) = cellCollapsePicker(self, indices) else {
                return
            }
            
            indices.remove(index)
            let state = State(
                grid: grid,
                fittestCellIndices: indices
            )
            states.append(state)
            grid[index].options = [option]
            
            do {
                try updateAffectedCells(at: index)
            } catch {
                mode = .backtrack
            }
            
            if duration() > timeout {
                throw GenerateError.timeout
            }
        }
    }
    
    private func getFittestCellIndices() -> Set<Int> {
        // candidate's indices with min entropy
        var indices: Set<Int> = []
        for (idx, cell) in grid.enumerated() {
            let cellEntropy = cell.entropy
            let cellPriority = cell.priority
            guard cellEntropy > 1 else {
                continue
            }
            guard let storedIndex = indices.first else {
                indices.insert(idx)
                continue
            }
            let minEntropy = grid[storedIndex].entropy
            let maxPriority = grid[storedIndex].priority
            if cellEntropy > minEntropy || cellPriority < maxPriority {
                continue
            }
            if minEntropy > cellEntropy || cellPriority > maxPriority {
                indices.removeAll()
            }
            indices.insert(idx)
        }
        return indices
    }
    
    private func updateAffectedCells(at index: Int) throws {
        var affected: Deque<Position> = Deque(
            Position
                .from(index: index, of: size)
                .adjacent(in: size)
        )
        var seen: Set<Int> = []
        while let position = affected.popFirst() {
            let i = position.index(in: size)
            guard !seen.contains(i), !grid[i].isCollapsed else {
                continue
            }
            seen.insert(i)
            guard let options = updatedOptions(for: position),
                  !options.isEmpty else {
                throw GenerateError.unableCollapse
            }
            guard options.count < grid[i].options.count else {
                continue
            }
            grid[i].options = options
            position
                .adjacent(in: size)
                .forEach {
                    affected.append($0)
                }
        }
    }
    
    func updatedOptions(for position: Position) -> TileIdSet? {
        [
            mergedOptions(position.up) { $0.downConstraints },
            mergedOptions(position.right) { $0.leftConstraints },
            mergedOptions(position.down) { $0.upConstraints },
            mergedOptions(position.left) { $0.rightConstraints }
        ]
            .compactMap { $0 }
            .reduce(nil) { (acc: TileIdSet?, val: TileIdSet) -> TileIdSet in
                guard let acc else {
                    return val
                }
                return acc.intersection(val)
            }
    }
    
    private func mergedOptions(
        _ position: Position,
        mapper: (Tile) -> TileIdSet
    ) -> TileIdSet? {
        guard position.isInside(of: size) else {
            return nil
        }
        let cell = grid[position.index(in: size)]
        return cell.options
            .compactMap {
                tileMap[$0]
            }
            .map {
                mapper($0)
            }
            .reduce(TileIdSet()) { acc, val in
                acc.union(val)
            }
    }
}

extension WaveFunctionCollapse: TileDataSource {
    func tileId(row: Int, col: Int) -> TileId? {
        let pos = Position(row: row, col: col)
        guard pos.isInside(of: size) else {
            return nil
        }
        let cell = grid[pos.index(in: size)]
        return cell.isCollapsed ? cell.options.first : nil
    }
}

extension WaveFunctionCollapse: CellCollapsePickerContext {
    func cell(at position: Matrix.Position) -> Cell {
        grid[position]
    }
    
    func cell(at index: Int) -> WaveFunctionCollapse.Cell {
        grid[index]
    }
    
    func tile(for id: TileId) -> Tile? {
        tileMap[id]
    }
    
    func gridSize() -> Matrix.Size {
        grid.size
    }
}

func defaultCellConstructor(index: Int, size: Matrix.Size, options: Set<TileId>) -> WaveFunctionCollapse.Cell {
    WaveFunctionCollapse.Cell(options: options)
}
