//
//  TankBuilder.swift
//  Tankodrome
//
//  Created by Sergey on 25.02.2025.
//

import Foundation

class TankBuilder {
    private var color: Color = .bronze
    private var cannon: Cannon = .standard
    private var hull: Hull = .hull1
    private var tracks: Tracks = .type1
    private var components: [Component] = []
    private var position: CGPoint = .zero
    
    static func random() -> TankBuilder {
        var builder = TankBuilder()
        
        if let color = Color.allCases.randomElement() {
            builder = builder.color(color)
        }
        if let cannon = Cannon.allCases.randomElement() {
            builder = builder.cannon(cannon)
        }
        if let hull = Hull.allCases.randomElement() {
            builder = builder.hull(hull)
        }
        if let tracks = Tracks.allCases.randomElement() {
            builder = builder.tracks(tracks)
        }
        
        return builder
    }
    
    func color(_ color: Color) -> Self {
        self.color = color
        return self
    }
    
    func cannon(_ cannon: Cannon) -> Self {
        self.cannon = cannon
        return self
    }
    
    func hull(_ hull: Hull) -> Self {
        self.hull = hull
        return self
    }
    
    func tracks(_ tracks: Tracks) -> Self {
        self.tracks = tracks
        return self
    }
    
    func addComponent(_ component: Component) -> Self {
        components.append(component)
        return self
    }
    
    func position(_ pos: CGPoint) -> Self {
        self.position = pos
        return self
    }
    
    func build() -> Tank {
        let hullImageName = [
            "Hull",
            color.rawValue,
            hull.rawValue
        ].joined(separator: "_")
        
        let cannonImageName = [
            "Gun",
            color.rawValue,
            cannon.rawValue
        ].joined(separator: "_")
        
        let tracksImageNames = ["A", "B"]
            .map {
                tracks.rawValue + "_" + $0
            }
        let sprite = Tank()
        sprite.setupAppearance(
            hullImageName: hullImageName,
            cannonImageName: cannonImageName,
            trackImageNames: tracksImageNames
        )
        components.forEach {
            sprite.addComponent($0)
        }
        sprite.position = position
        return sprite
    }
    
    enum Color: String, CaseIterable {
        case bronze = "A"
        case yellow = "B"
        case cyan = "C"
        case blue = "D"
    }
    
    enum Cannon: String, CaseIterable {
        case standard = "01"
        case lightImproved = "02"
        case semiStandard = "03"
        case light = "04"
        case standardImproved = "05"
        case double = "06"
        case heavy = "07"
        case heavyImproved = "08"
    }
    
    enum Hull: String, CaseIterable {
        case hull1 = "01"
        case hull2 = "02"
        case hull3 = "03"
        case hull4 = "04"
        case hull5 = "05"
        case hull6 = "06"
        case hull7 = "07"
        case hull8 = "08"
    }
    
    enum Tracks: String, CaseIterable {
        case type1 = "Track_1"
        case type2 = "Track_2"
        case type3 = "Track_3"
    }
}
