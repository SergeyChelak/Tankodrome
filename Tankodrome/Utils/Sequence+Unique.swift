//
//  Sequence+Unique.swift
//  Tankodrome
//
//  Created by Sergey on 26.02.2025.
//

import Foundation

extension Sequence {
    public func unique<T: Hashable>(by propertyAccessor: (Element) -> T) -> [Element] {
        var seen: Set<T> = []
        var result: [Element] = []
        for element in self {
            let property = propertyAccessor(element)
            if !seen.contains(property) {
                result.append(element)
                seen.insert(property)
            }
        }
        return result
    }
}

extension Sequence where Element: Hashable {
    public func unique() -> [Element] {
        unique { $0 }
    }
}
