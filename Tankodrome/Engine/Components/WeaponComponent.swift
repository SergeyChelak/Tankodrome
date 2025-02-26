//
//  WeaponComponent.swift
//  Tankodrome
//
//  Created by Sergey on 27.02.2025.
//

import Foundation

final class WeaponComponent: Component {
    enum State {
        case recharge(TimeInterval)
        case ready
    }
    
    let model: WeaponModel
    var state: State = .ready
    
    init(model: WeaponModel) {
        self.model = model
    }
}

enum WeaponModel: String, CaseIterable {
    case sniper = "Sniper_Shell"
    case light = "Light_Shell"
    case medium = "Medium_Shell"
    case heavy = "Heavy_Shell"
    case plasma = "Plasma"
    
    var speed: CGFloat {
        switch self {
        case .sniper:
            return 2500
        case .light:
            return 1700
        case .medium:
            return 1500
        case .heavy:
            return 1200
        case .plasma:
            return 2000
        }
    }
    
    var damage: CGFloat {
        switch self {
        case .sniper:
            return 5
        case .light:
            return 15
        case .medium:
            return 25
        case .heavy:
            return 35
        case .plasma:
            return 30
        }
    }
    
    var rechargeTime: TimeInterval {
        // TODO: tune setting for each type
        0.5
    }
}
