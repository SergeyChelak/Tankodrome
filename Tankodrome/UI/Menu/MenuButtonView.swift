//
//  MenuButtonView.swift
//  Tankodrome
//
//  Created by Sergey on 05.04.2025.
//

import SwiftUI

struct MenuButtonView: View {
    @Environment(\.themeProvider) var themeProvider
    let title: String
    let callback: () -> Void
    @State
    private var isHovering = false
    
    var body: some View {
        Text(title)
            .font(.system(size: 35))
            .foregroundStyle(themeProvider.menuHeader)
            .contentShape(Rectangle())
            .onTapGesture(perform: callback)
    }
}

#Preview {
    MenuButtonView(title: "Title", callback: {})
}
