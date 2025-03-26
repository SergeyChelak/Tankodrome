//
//  WaveFunctionCollapse+Picker.swift
//  Tankodrome
//
//  Created by Sergey on 25.03.2025.
//

import Foundation

protocol CellCollapsePickerContext {
    func cell(at position: Matrix.Position) -> WaveFunctionCollapse.Cell
    func cell(at index: Int) -> WaveFunctionCollapse.Cell
    func tile(for id: TileId) -> WaveFunctionCollapse.Tile?
    func gridSize() -> Matrix.Size
}

typealias CellCollapse = (Int, TileId)

func defaultCellCollapsePicker(
    _ context: CellCollapsePickerContext,
    _ indices: Set<Int>
) -> CellCollapse? {
    guard let index = indices.randomElement(),
          let option = context.cell(at: index).options.randomElement() else {
        return nil
    }
    return (index, option)
}
