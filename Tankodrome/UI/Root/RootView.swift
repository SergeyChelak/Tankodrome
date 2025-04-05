//
//  RootView.swift
//  Tankodrome
//
//  Created by Sergey on 03.04.2025.
//

import SwiftUI

struct RootView: View {
    let viewFactory: GameViewFactory
    @StateObject
    var context: AppContext
    //var viewModel: RootViewModel
    
    var body: some View {
        ZStack {
            Image("Ground_Tile_02_C")
                .resizable(resizingMode: .tile)
                .ignoresSafeArea()
            contentViewHolder.view
        }
    }
    
    private var contentViewHolder: ViewHolder {
        switch context.flow {
        case .play(let flow):
            viewFactory.gameView(flow: flow)
        case .menu(let flow):
            viewFactory.menuView(flow: flow)
        }
    }
}

//#Preview {
//    RootView()
//}
