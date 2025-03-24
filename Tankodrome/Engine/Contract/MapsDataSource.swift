//
//  MapsDataSource.swift
//  Tankodrome
//
//  Created by Sergey on 24.03.2025.
//

import Foundation

protocol MapsDataSource {
    var maps: [String: TiledMap] { get }
    
//    func load() throws
}
