//
//  MenuButtonView.swift
//  Tankodrome
//
//  Created by Sergey on 05.04.2025.
//

import SwiftUI

struct MenuButtonView: View {
    let title: String
    let callback: () -> Void
    @State
    private var isHovering = false
    
    var body: some View {
        Text(title)
            .font(.system(size: 35))
            .contentShape(Rectangle())
            .shadow(
                color: .black,
                radius: isHovering ? 12.0 : 1.0
            )
            .onHover {
                self.isHovering = $0
            }
            .onTapGesture(perform: callback)
    }
}

#Preview {
    MenuButtonView(title: "Title", callback: {})
}
