//
//  SKNode+LazyUserData.swift
//  Tankodrome
//
//  Created by Sergey on 25.02.2025.
//

import Foundation
import SpriteKit

extension SKNode {
    var lazyUserData: NSMutableDictionary {
        let data = userData ?? [:]
        userData = data
        return data
    }
}
