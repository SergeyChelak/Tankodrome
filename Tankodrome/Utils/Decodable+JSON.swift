//
//  Decodable+JSON.swift
//  Tankodrome
//
//  Created by Sergey on 09.03.2025.
//

import Foundation

enum DecodeError: Error {
    case badPath(String)
}

extension Decodable {
    static func from(
        file: String,
        type: String = "json",
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> Self {
        guard let path = Bundle.main.path(forResource: file, ofType: type) else {
            throw DecodeError.badPath("name: \(file), type: \(type)")
        }
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        return try decoder.decode(Self.self, from: data)
    }
}
