//
//  Projectile+Builder.swift
//  Tankodrome
//
//  Created by Sergey on 25.02.2025.
//

import Foundation

extension Projectile {
    class Builder {
        private var model: WeaponModel = .medium
        private var components: [Component] = []
        
        func model(_ model: WeaponModel) -> Self {
            self.model = model
            return self
        }
        
        func addComponent(_ component: Component) -> Self {
            components.append(component)
            return self
        }
        
        func build() -> Projectile {
            let sprite = Projectile()
            sprite.setupAppearance(imageName: model.rawValue)
            sprite.setupPhysics()
            components.forEach {
                sprite.addComponent($0)
            }
            return sprite
        }
    }
}
