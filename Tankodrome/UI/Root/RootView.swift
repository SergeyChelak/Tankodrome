//
//  RootView.swift
//  Tankodrome
//
//  Created by Sergey on 03.04.2025.
//

import SwiftUI

struct RootView: View {
    // TODO: set outside
    let viewFactory = GameViewFactory()
    @StateObject
    var viewModel: RootViewModel
    
    var body: some View {
        ZStack {
            Image("Ground_Tile_02_C")
                .resizable(resizingMode: .tile)
                .ignoresSafeArea()
            contentViewHolder.view
        }
    }
    
    private var contentViewHolder: ViewHolder {
        switch viewModel.state {
        case .play:
            viewFactory.gameView(flow: viewModel.gameFlow)
        case .mainMenu:
            viewFactory.menuView(viewModel)
        default:
            ViewHolder(Text("Need to implement..."))
        }
    }
}

//#Preview {
//    RootView()
//}
