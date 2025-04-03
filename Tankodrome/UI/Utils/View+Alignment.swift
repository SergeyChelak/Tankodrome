//
//  View+Alignment.swift
//  Tankodrome
//
//  Created by Sergey on 03.04.2025.
//

import SwiftUI

struct AlignmentViewModifier: ViewModifier {
    enum Alignment {
        case leading, trailing, top, bottom
    }
    
    private let alignment: Alignment
    
    init(_ alignment: Alignment) {
        self.alignment = alignment
    }
    
    func body(content: Content) -> some View {
        switch alignment {
        case .leading:
            HStack {
                content
                Spacer()
            }
        case .trailing:
            HStack {
                Spacer()
                content
            }
        case .top:
            VStack {
                content
                Spacer()
            }
        case .bottom:
            VStack {
                Spacer()
                content
            }
        }
    }
}

extension View {
    func alignTo(_ alignment: AlignmentViewModifier.Alignment) -> some View {
        let modifier = AlignmentViewModifier(alignment)
        return self.modifier(modifier)
    }
    
    func alignToLeadingTop() -> some View {
        self.alignTo(.leading)
            .alignTo(.top)
    }
}

