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
    
    var contentViewHolder: ViewHolder {
        switch viewModel.state {
        case .play:
            viewFactory.gameView(flow: viewModel.gameFlow)
        case .pause:
            ViewHolder(Text("Pause view isn't implemented yet"))
        case .mainMenu:
            viewFactory.menuView(viewModel)
        }
    }
}

//#Preview {
//    RootView()
//}
