//
//  SKNode+Attributes.swift
//  Tankodrome
//
//  Created by Sergey on 25.02.2025.
//

import Foundation
import SpriteKit

extension SKNode {
    func setAttribute<T>(name: String, _ value: T) {
        lazyUserData[name.attribute] = value
    }
    
    func removeAttribute(name: String) {
        lazyUserData.removeObject(forKey: name.attribute)
    }
    
    func getAttribute<T>(name: String) -> T? {
        lazyUserData[name.attribute] as? T
    }
}

fileprivate extension String {
    var attribute: String {
        "#attribute#" + self
    }
}
