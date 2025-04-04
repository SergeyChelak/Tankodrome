//
//  View+Fade.swift
//  Tankodrome
//
//  Created by Sergey on 05.04.2025.
//

import SwiftUI

struct FadeInViewModifier: ViewModifier {
    private let duration: TimeInterval
    @State
    private var opacity: CGFloat = 0.0
    
    init(duration: TimeInterval) {
        self.duration = duration
    }
    
    func body(content: Content) -> some View {
        content
            .opacity(opacity)
            .onAppear() {
                withAnimation(.easeIn(duration: duration)) {
                    opacity = 1.0
                }
            }
    }
}

extension View {
    func fadeIn(duration: TimeInterval = 0.35) -> some View {
        let modifier = FadeInViewModifier(duration: duration)
        return self.modifier(modifier)
    }
}
