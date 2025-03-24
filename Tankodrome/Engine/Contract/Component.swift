//
//  Component.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation

typealias ComponentIdentifier = String

protocol Component {
    //
}

protocol ComponentContainable {
    var allComponents: [Component] { get }

    func addComponents(_ items: Component...)
    
    func addComponent<T: Component>(_ component: T)
    
    func removeComponent<T: Component>(of type: T.Type)
    
    func getComponent<T: Component>(of type: T.Type) -> T?
    
    func hasComponent<T: Component>(of type: T.Type) -> Bool
}
