//
//  ViewHolder.swift
//  Tankodrome
//
//  Created by Sergey on 03.04.2025.
//

import SwiftUI

class ViewHolder {
    let view: AnyView
    
    init<V: View>(_ view: V) {
        self.view = AnyView(view)
    }
    
    init(_ anyView: AnyView) {
        self.view = anyView
    }
    
    static let empty: ViewHolder = ViewHolder(EmptyView())
}
