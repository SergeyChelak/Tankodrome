//
//  SKNode+ComponentContainable.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation
import SpriteKit

extension SKNode: ComponentContainable {
    func addComponents(_ items: Component...) {
        items.forEach {
            addComponent($0)
        }
    }
    
    func addComponent<T: Component>(_ component: T) {
        let key = identifier(of: T.self)
        lazyUserData[key] = component
    }
    
    func removeComponent<T: Component>(of type: T.Type) {
        let key = identifier(of: T.self)
        lazyUserData.removeObject(forKey: key)
    }
    
    func getComponent<T: Component>(of type: T.Type) -> T? {
        let key = identifier(of: T.self)
        return lazyUserData[key] as? T
    }
    
    func hasComponent<T: Component>(of type: T.Type) -> Bool {
        getComponent(of: type) != nil
    }
    
    var allComponents: [Component] {
        lazyUserData.allValues
            .compactMap {
                $0 as? Component
            }
    }
}

fileprivate func identifier<T: Component>(of type: T.Type) -> ComponentIdentifier {
    "#component#" + String(describing: type.self)
}
