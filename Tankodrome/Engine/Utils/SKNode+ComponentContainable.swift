//
//  SKNode+ComponentContainable.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import Foundation
import SpriteKit
import os

extension SKNode: ComponentContainable {
    func addComponents(_ items: Component...) {
        items.forEach {
            addComponent($0)
        }
    }
    
    func addComponents(_ items: [Component]) {
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

/// Memoized type → key mapping. `String(describing:)` performs runtime reflection
/// on every call (~590 ns); component lookups happen 1000+ times per frame across
/// the systems, so the keys are computed once per type and cached (~120 ns/call,
/// ≈5x faster). Lock-protected because GameFlow/HudViewModel read components from
/// a background queue while the game loop reads them on the main thread.
private let componentKeyCache = OSAllocatedUnfairLock<[ObjectIdentifier: ComponentIdentifier]>(initialState: [:])

fileprivate func identifier<T: Component>(of type: T.Type) -> ComponentIdentifier {
    let id = ObjectIdentifier(type)
    if let cached = componentKeyCache.withLock({ $0[id] }) {
        return cached
    }
    // Computed outside the lock (metatypes aren't Sendable); two threads may
    // rarely compute the same key concurrently, which is harmless.
    let key = "#component#" + String(describing: type)
    componentKeyCache.withLock { $0[id] = key }
    return key
}
