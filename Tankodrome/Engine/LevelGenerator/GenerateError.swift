//
//  GenerateError.swift
//  Tankodrome
//
//  Created by Sergey on 24.02.2025.
//

import Foundation

enum GenerateError: Error {
    case invalidState
    case unableCollapse
    case timeout
    case tileSetNotSpecified
    case multipleOrEmptyTileSet
    case missingLayer(String)
    case missingTile
}
