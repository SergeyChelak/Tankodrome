//
//  MapElements.swift
//  Tankodrome
//
//  Created by Sergey on 24.02.2025.
//

import Foundation

struct MapElements: Decodable {
    let landscape: [Tile]
    let objects: [Object]
}

extension MapElements {
    enum LoadError: Error {
        case unknownBodyType(String)
        case badPath(String)
    }

    static func load(filename: String, type: String) throws -> Self {
        guard let path = Bundle.main.path(forResource: filename, ofType: type) else {
            throw LoadError.badPath("name: \(filename), type: \(type)")
        }
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data)
    }
}

