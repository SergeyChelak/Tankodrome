//
//  MenuPageDataSource.swift
//  Tankodrome
//
//  Created by Sergey on 05.04.2025.
//

import Foundation

struct MenuPageElement {
    let name: String
    // TODO: see comment
    /*
     replace action to element type:
        - button
        - toggle
        - circular selector
        - empty/spacer
     */
    let action: MenuFlow.Action
    
    init(_ name: String, _ action: MenuFlow.Action) {
        self.name = name
        self.action = action
    }
}

protocol MenuPageDataSource {
    var title: String { get }
    var elements: [MenuPageElement] { get }
    func handle(action: MenuFlow.Action)
}

typealias MenuActionCallback = (MenuFlow.Action) -> Void
