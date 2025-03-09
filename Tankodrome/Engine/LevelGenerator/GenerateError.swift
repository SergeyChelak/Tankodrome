//
//  GenerateError.swift
//  Tankodrome
//
//  Created by Sergey on 24.02.2025.
//

import Foundation

enum GenerateError: Error {
    case unknownBodyType(String)
    case invalidConnectorValue(String)
    case invalidState
    case unableCollapse
    case wrongTileSet(String)
    case timeout
}
