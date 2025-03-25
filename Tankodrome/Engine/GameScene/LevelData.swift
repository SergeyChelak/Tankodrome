//
//  LevelData.swift
//  Tankodrome
//
//  Created by Sergey on 25.03.2025.
//

import Foundation

struct LevelData {
    typealias LandscapeGrid = Matrix.ArrayWrapper<String>
    
    struct ContourObject {
        let blockPosition: Matrix.Position
        let rectangle: CGRect
    }
    
    let mapBlockSize: Matrix.Size
    let landscapeGrid: LandscapeGrid
    let contourObjects: [ContourObject]
}
