//
//  HealthComponent.swift
//  Tankodrome
//
//  Created by Sergey on 26.02.2025.
//

import Foundation

final class HealthComponent: ValueWrapper<CGFloat>, Component {
    let max: CGFloat
    
    override init(value: CGFloat) {
        self.max = value
        super.init(value: value)
    }
}
