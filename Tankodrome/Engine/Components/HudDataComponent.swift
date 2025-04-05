//
//  HudDataComponent.swift
//  Tankodrome
//
//  Created by Sergey on 04.04.2025.
//

import Foundation

final class HudDataComponent: ValueWrapper<HudData>, Component { }

struct HudData {
    let totalEnemies: Int
    var enemiesLeft: Int
    var playerHealth: CGFloat
}
