//
//  HudAction.swift
//  Tankodrome
//
//  Created by Sergey on 03.03.2025.
//

import Foundation

enum HudAction {
    case replay, nextLevel
    
    var uiName: String {
        switch self {
        case .replay:
            "Replay"
        case .nextLevel:
            "Next"
        }
    }
}
