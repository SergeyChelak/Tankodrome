//
//  VelocityComponent.swift
//  Tankodrome
//
//  Created by Sergey on 26.02.2025.
//

import Foundation

final class VelocityComponent: ValueWrapper<CGFloat>, Component {
    let limit: CGFloat

    init(value: CGFloat, limit: CGFloat) {
        self.limit = limit
        super.init(value: value)
    }
}
