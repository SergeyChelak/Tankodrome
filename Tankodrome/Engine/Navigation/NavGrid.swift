//
//  NavGrid.swift
//  Tankodrome
//
//  Created by Sergey on 17.07.2026.
//

import Foundation

/// Coarse occupancy grid used by the NPC AI for pathfinding around walls.
///
/// Built once at level-load time by rasterizing the level's wall rectangles into
/// blocked cells (one cell ≈ one landscape tile). Coordinates are SpriteKit world
/// space: origin bottom-left, +Y up, so grid row 0 is the bottom row.
struct NavGrid {
    let cols: Int
    let rows: Int
    let tileSize: CGSize

    private let blocked: [Bool]

    /// - Parameters:
    ///   - wallRects: interior obstacle rectangles in world coordinates.
    ///   - clearance: extra padding (≈ half a tank width) so paths keep the tank
    ///     from clipping wall corners.
    init(cols: Int, rows: Int, tileSize: CGSize, wallRects: [CGRect], clearance: CGFloat) {
        self.cols = max(0, cols)
        self.rows = max(0, rows)
        self.tileSize = tileSize

        let cols = self.cols
        let rows = self.rows
        var blocked = [Bool](repeating: false, count: cols * rows)
        guard cols > 0, rows > 0, tileSize.width > 0, tileSize.height > 0 else {
            self.blocked = blocked
            return
        }

        // Block the perimeter ring: the outer border frame the level is wrapped in.
        for c in 0..<cols {
            blocked[c] = true                      // bottom row
            blocked[(rows - 1) * cols + c] = true  // top row
        }
        for r in 0..<rows {
            blocked[r * cols] = true               // left column
            blocked[r * cols + (cols - 1)] = true  // right column
        }

        // Rasterize interior walls, dilated by `clearance`.
        for rect in wallRects {
            let expanded = rect.insetBy(dx: -clearance, dy: -clearance)
            let minCol = Int(floor(expanded.minX / tileSize.width)).clamped(0, cols - 1)
            let maxCol = Int(floor(expanded.maxX / tileSize.width)).clamped(0, cols - 1)
            let minRow = Int(floor(expanded.minY / tileSize.height)).clamped(0, rows - 1)
            let maxRow = Int(floor(expanded.maxY / tileSize.height)).clamped(0, rows - 1)
            guard minCol <= maxCol, minRow <= maxRow else {
                continue
            }
            for r in minRow...maxRow {
                for c in minCol...maxCol {
                    blocked[r * cols + c] = true
                }
            }
        }
        self.blocked = blocked
    }

    // MARK: - Coordinate conversion

    func cell(at point: CGPoint) -> Cell {
        let col = Int(floor(point.x / tileSize.width)).clamped(0, cols - 1)
        let row = Int(floor(point.y / tileSize.height)).clamped(0, rows - 1)
        return Cell(row: row, col: col)
    }

    func center(of cell: Cell) -> CGPoint {
        CGPoint(
            x: (CGFloat(cell.col) + 0.5) * tileSize.width,
            y: (CGFloat(cell.row) + 0.5) * tileSize.height
        )
    }

    func isWalkable(_ cell: Cell) -> Bool {
        guard cell.row >= 0, cell.row < rows, cell.col >= 0, cell.col < cols else {
            return false
        }
        return !blocked[cell.row * cols + cell.col]
    }

    // MARK: - Pathfinding

    /// A* over 8-neighbours (no corner cutting). Returns world-space waypoints from
    /// just after `start` up to `goal`, or `[]` when unreachable. The start cell
    /// itself is omitted so the caller steers toward the next cell immediately.
    func findPath(from start: CGPoint, to goal: CGPoint) -> [CGPoint] {
        guard cols > 0, rows > 0 else {
            return []
        }
        let startCell = cell(at: start)
        guard let goalCell = nearestWalkable(to: cell(at: goal)) else {
            return []
        }
        if startCell == goalCell {
            return [center(of: goalCell)]
        }

        let count = cols * rows
        var gScore = [CGFloat](repeating: .greatestFiniteMagnitude, count: count)
        var cameFrom = [Int](repeating: -1, count: count)
        var closed = [Bool](repeating: false, count: count)

        let startIndex = startCell.row * cols + startCell.col
        let goalIndex = goalCell.row * cols + goalCell.col
        gScore[startIndex] = 0

        var frontier = MinHeap()
        frontier.push(index: startIndex, priority: heuristic(startCell, goalCell))

        // Bound the search so an unreachable goal can't explore the whole grid.
        var expansions = 0
        let expansionBudget = min(count, 4000)

        while let current = frontier.pop() {
            if current == goalIndex {
                return reconstruct(cameFrom: cameFrom, goalIndex: goalIndex)
            }
            if closed[current] {
                continue
            }
            closed[current] = true

            expansions += 1
            if expansions > expansionBudget {
                return []
            }

            let cr = current / cols
            let cc = current % cols
            for (dr, dc) in NavGrid.neighbourOffsets {
                let nr = cr + dr
                let nc = cc + dc
                guard nr >= 0, nr < rows, nc >= 0, nc < cols else {
                    continue
                }
                let neighbour = Cell(row: nr, col: nc)
                guard isWalkable(neighbour) else {
                    continue
                }
                // Disallow diagonal moves that clip a wall corner.
                if dr != 0 && dc != 0 {
                    guard isWalkable(Cell(row: cr, col: nc)),
                          isWalkable(Cell(row: nr, col: cc)) else {
                        continue
                    }
                }
                let neighbourIndex = nr * cols + nc
                if closed[neighbourIndex] {
                    continue
                }
                let stepCost: CGFloat = (dr != 0 && dc != 0) ? 1.41421356 : 1.0
                let tentative = gScore[current] + stepCost
                if tentative < gScore[neighbourIndex] {
                    gScore[neighbourIndex] = tentative
                    cameFrom[neighbourIndex] = current
                    frontier.push(
                        index: neighbourIndex,
                        priority: tentative + heuristic(neighbour, goalCell)
                    )
                }
            }
        }
        return []
    }

    // MARK: - Helpers

    private static let neighbourOffsets: [(Int, Int)] = [
        (-1, 0), (1, 0), (0, -1), (0, 1),
        (-1, -1), (-1, 1), (1, -1), (1, 1)
    ]

    private func heuristic(_ a: Cell, _ b: Cell) -> CGFloat {
        // Octile distance — admissible for 8-connected grids.
        let dx = CGFloat(abs(a.col - b.col))
        let dy = CGFloat(abs(a.row - b.row))
        return max(dx, dy) + (1.41421356 - 1.0) * min(dx, dy)
    }

    private func reconstruct(cameFrom: [Int], goalIndex: Int) -> [CGPoint] {
        var cells: [Cell] = []
        var current = goalIndex
        while current != -1 {
            cells.append(Cell(row: current / cols, col: current % cols))
            current = cameFrom[current]
        }
        // `cells` is goal→start; drop the start cell and reverse to start→goal.
        return cells.dropLast().reversed().map { center(of: $0) }
    }

    /// Snaps a (possibly blocked) target cell to the closest walkable cell via an
    /// expanding ring search, so a target standing inside wall-clearance is still
    /// reachable. Bounded radius keeps it cheap.
    private func nearestWalkable(to cell: Cell) -> Cell? {
        if isWalkable(cell) {
            return cell
        }
        let maxRadius = max(cols, rows)
        var radius = 1
        while radius <= maxRadius {
            for dr in -radius...radius {
                for dc in -radius...radius {
                    guard abs(dr) == radius || abs(dc) == radius else {
                        continue // only the ring at this radius
                    }
                    let candidate = Cell(row: cell.row + dr, col: cell.col + dc)
                    if isWalkable(candidate) {
                        return candidate
                    }
                }
            }
            radius += 1
        }
        return nil
    }

    struct Cell: Equatable {
        let row: Int
        let col: Int
    }
}

// MARK: - Priority queue

/// Minimal binary min-heap keyed by priority. Self-contained so navigation carries
/// no external package dependency.
private struct MinHeap {
    private var elements: [(index: Int, priority: CGFloat)] = []

    var isEmpty: Bool { elements.isEmpty }

    mutating func push(index: Int, priority: CGFloat) {
        elements.append((index, priority))
        siftUp(from: elements.count - 1)
    }

    mutating func pop() -> Int? {
        guard !elements.isEmpty else {
            return nil
        }
        elements.swapAt(0, elements.count - 1)
        let last = elements.removeLast()
        if !elements.isEmpty {
            siftDown(from: 0)
        }
        return last.index
    }

    private mutating func siftUp(from start: Int) {
        var child = start
        var parent = (child - 1) / 2
        while child > 0 && elements[child].priority < elements[parent].priority {
            elements.swapAt(child, parent)
            child = parent
            parent = (child - 1) / 2
        }
    }

    private mutating func siftDown(from start: Int) {
        var parent = start
        let count = elements.count
        while true {
            let left = parent * 2 + 1
            let right = parent * 2 + 2
            var candidate = parent
            if left < count && elements[left].priority < elements[candidate].priority {
                candidate = left
            }
            if right < count && elements[right].priority < elements[candidate].priority {
                candidate = right
            }
            if candidate == parent {
                return
            }
            elements.swapAt(parent, candidate)
            parent = candidate
        }
    }
}

private extension Int {
    func clamped(_ lower: Int, _ upper: Int) -> Int {
        Swift.min(Swift.max(self, lower), upper)
    }
}
