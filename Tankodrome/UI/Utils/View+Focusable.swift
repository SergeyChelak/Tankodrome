//
//  View+Focusable.swift
//  Tankodrome
//
//  Created by Sergey on 03.03.2025.
//

import SwiftUI

struct FocusableViewModifier: ViewModifier {
    @FocusState private var isFocused: Bool
    
    func body(content: Content) -> some View {
        content
            .focused($isFocused)
            .onAppear {
                isFocused = true
            }
    }
}

extension View {
    func setFocused() -> some View {
        modifier(FocusableViewModifier())
    }
}
