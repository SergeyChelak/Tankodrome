//
//  Tank+Tracks.swift
//  Tankodrome
//
//  Created by Sergey on 25.02.2025.
//

import Foundation
import SpriteKit

extension Tank {
    class Tracks: SKSpriteNode {
        private var trackNodes: [SKSpriteNode] = []
        private var trackTextures: [SKTexture] = []
        private var isTracksAnimating = false
        
        func setupTrackData(_ trackImageNames: [String]) {
            trackTextures = trackImageNames.compactMap {
                SKTexture(imageNamed: $0)
            }
            guard let texture = trackTextures.first else {
                return
            }

            let xOffset = 0.25 * self.size.width + 5
            trackNodes = [-1, 1]
                .map { i in
                    let node = SKSpriteNode(texture: texture)
                    node.zPosition = 8
                    node.position -= CGPoint(x: 0, y: CGFloat(i) * xOffset)
                    return node
                }
            addChildren(trackNodes)
        }
                
        func setTrackAnimated(_ isAnimating: Bool) {
            guard isTracksAnimating != isAnimating else {
                return
            }
            isTracksAnimating = isAnimating
            trackNodes
                .forEach {
                    guard isAnimating else {
                        $0.removeAllActions()
                        return
                    }
                    let action: SKAction = .animate(
                        with: trackTextures,
                        timePerFrame: 0.005
                    )
                    $0.run(.repeatForever(action))
                }
        }

    }
}
