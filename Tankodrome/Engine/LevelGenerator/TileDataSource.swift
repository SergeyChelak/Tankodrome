//
//  TileDataSource.swift
//  Tankodrome
//
//  Created by Sergey on 24.02.2025.
//

import Foundation

typealias TileId = String

protocol TileDataSource {
    func tileId(row: Int, col: Int) -> TileId?
}
