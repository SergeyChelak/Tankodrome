//
//  BlockPositionConverter.swift
//  Tankodrome
//
//  Created by Sergey on 23.04.2025.
//

import Foundation

struct BlockPositionConverter {
    private let levelRect: CGRect
    private let blockSize: CGSize
    
    init(levelData: LevelData, levelRect: CGRect, tileSize: CGSize) {
        self.levelRect = levelRect
        self.blockSize = levelData.mapBlockSize.cgSizeValue * tileSize
    }
    
    func absolutePoint(_ point: LevelData.BlockPoint) -> CGPoint {
        let offset = offset(point)
        var result = offset + point.point
        result.y = levelRect.size.height - result.y
        return result
    }
    
    func absoluteRectangle(_ obj: LevelData.ContourObject) -> CGRect {
        let offset = offset(obj)        
        let origin = obj.rectangle.origin + offset
        return CGRect(origin: origin, size: obj.rectangle.size)
    }
    
    private func offset(_ point: LevelData.Positionable) -> CGPoint {
        CGPoint(
            x: blockSize.width * CGFloat(point.blockPosition.col),
            y: blockSize.height * CGFloat(point.blockPosition.row)
        )
    }
}
