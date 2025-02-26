//
//  Tank.swift
//  Tankodrome
//
//  Created by Sergey on 25.02.2025.
//

import Foundation
import SpriteKit

class Tank: SKSpriteNode {
    let tracks = Tracks()
    
    func setupAppearance(
        hullImageName: String,
        cannonImageName: String,
        trackImageNames: [String]
        
    ) {
        setupHull(hullImageName)
        setupCannon(cannonImageName)
        setupTrackData(trackImageNames: trackImageNames)
    }
    
    private func setupHull(_ hullImageName: String) {
        let hull = SKSpriteNode(imageNamed: hullImageName)
        hull.zPosition = 9
        self.size = hull.size
        addChild(hull)
    }
    
    private func setupCannon(_ cannonImageName: String) {
        let cannon = SKSpriteNode(imageNamed: cannonImageName)
        cannon.zPosition = 10
        cannon.anchorPoint = CGPoint(x: 0.5, y: 0.2)
        cannon.position = CGPoint(x: 0, y: -20)
        addChild(cannon)
    }
    
    private func setupTrackData(trackImageNames: [String]) {
        tracks.size = self.size
        tracks.setupTrackData(trackImageNames)
        addChild(tracks)
    }
                
    func setupPhysics() {
        let bodySize = self.size * CGSize(width: 1.0, height: 0.7)
        let body = SKPhysicsBody(rectangleOf: bodySize)
        body.isDynamic = true
        body.allowsRotation = true
        body.affectedByGravity = false
        body.setCategory(.tank)
        body.contactTestBitMask = UInt32.max
        self.physicsBody = body
    }
}
