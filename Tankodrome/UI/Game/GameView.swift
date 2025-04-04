//
//  GameView.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    @StateObject
    var viewModel: GameViewModel

    var body: some View {
        GeometryReader { proxy in
            contentView(proxy.size)
        }
    }
    
    private func contentView(_ size: CGSize) -> some View {
        ZStack {
            composeGameScene(viewModel.gameFlow)
            composeHudView(viewModel.gameFlow)
        }
        .fadeIn()
    }
}

//#Preview {
//    GameView(viewModel: GameViewModel())
//}
