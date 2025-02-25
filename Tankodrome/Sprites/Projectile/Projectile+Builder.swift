//
//  Projectile+Builder.swift
//  Tankodrome
//
//  Created by Sergey on 25.02.2025.
//

import Foundation

extension Projectile {
    class Builder {
        private var appearance: Appearance = .medium
        private var components: [Component] = []
        
        func appearance(_ appearance: Appearance) -> Self {
            self.appearance = appearance
            return self
        }
        
        func addComponent(_ component: Component) -> Self {
            components.append(component)
            return self
        }
        
        func build() -> Projectile {
            let sprite = Projectile()
            sprite.setupAppearance(imageName: appearance.rawValue)
            sprite.setupPhysics()
            components.forEach {
                sprite.addComponent($0)
            }
            return sprite
        }
        
        enum Appearance: String, CaseIterable {
            case sniper = "Sniper_Shell"
            case light = "Light_Shell"
            case medium = "Medium_Shell"
            case heavy = "Heavy_Shell"
            case plasma = "Plasma"
        }
    }
}
