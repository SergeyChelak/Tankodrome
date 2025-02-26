//
//  VelocityComponent.swift
//  Tankodrome
//
//  Created by Sergey on 26.02.2025.
//

import Foundation

final class VelocityComponent: Component {
    let limit: CGFloat
    var value: CGFloat
    
    init(value: CGFloat, limit: CGFloat) {
        self.value = value
        self.limit = limit
    }
}
