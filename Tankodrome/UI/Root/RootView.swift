//
//  RootView.swift
//  Tankodrome
//
//  Created by Sergey on 03.04.2025.
//

import SwiftUI

struct RootView: View {
//    private let factory: TankodromeViewFactory
//    
//    init(factory: TankodromeViewFactory) {
//        self.factory = factory
//    }
    
    var body: some View {
        ZStack {
            Image("Ground_Tile_02_C")
                .resizable(resizingMode: .tile)
                .ignoresSafeArea()
            Text("Put game view here")
        }
    }
}

#Preview {
    RootView()
}
