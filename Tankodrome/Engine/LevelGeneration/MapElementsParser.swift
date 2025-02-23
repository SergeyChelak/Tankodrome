//
//  MapElementsParser.swift
//  Tankodrome
//
//  Created by Sergey on 24.02.2025.
//

import Foundation

enum MapElementsParseError: Error {
    case unknownBodyType(String)
    case badPath(String)
}

func parseMapElements() throws -> MapElements {
    let name = "MapElements"
    let type = "json"
    guard let path = Bundle.main.path(forResource: name, ofType: type) else {
        throw MapElementsParseError.badPath("name: \(name), type: \(type)")
    }
    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    let decoder = JSONDecoder()
    let elements = try decoder.decode(MapElements.self, from: data)
    
    return elements
}
