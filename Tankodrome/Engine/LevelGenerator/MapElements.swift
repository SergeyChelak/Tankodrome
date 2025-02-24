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

    struct Object: Decodable {
        let name: String
        let rotate: String
        let landscape: [String]
        let body: Body
    }
    
    enum Body: Decodable {
        case circle(pole: String, radius: Int)
        case rectangle(pole: String, width: Int, height: Int)
        
        private enum CodingKeys: String, CodingKey {
            case shape, pole, radius, width, height
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let shape = try container.decode(String.self, forKey: .shape)
            let pole = try container.decode(String.self, forKey: .pole)
            switch shape {
            case "rectangle":
                let width = try container.decode(Int.self, forKey: .width)
                let height = try container.decode(Int.self, forKey: .height)
                self = .rectangle(pole: pole, width: width, height: height)
            case "circle":
                let radius = try container.decode(Int.self, forKey: .radius)
                self = .circle(pole: pole, radius: radius)
            default:
                throw GenerateError.unknownBodyType(shape)
            }
        }
    }
    
    struct Tile: Decodable {
        let name: String
        let group: String
        let connectors: Connectors
        
        struct Connectors: Decodable {
            let up: String
            let right: String
            let down: String
            let left: String
        }
    }
}


extension MapElements {
    static let empty = MapElements(landscape: [], objects: [])
}
