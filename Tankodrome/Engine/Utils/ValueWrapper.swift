//
//  ValueWrapper.swift
//  Tankodrome
//
//  Created by Sergey on 26.02.2025.
//

import Foundation

class ValueWrapper<T> {
    var value: T
    
    init(value: T) {
        self.value = value
    }
}
