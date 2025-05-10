//
//  GameView.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    let sceneViewHolder: ViewHolder
    let hudViewHolder: ViewHolder

    var body: some View {
        ZStack {
            sceneViewHolder.view
            hudViewHolder.view
        }
        .fadeIn()
    }
}

//#Preview {
//    GameView(viewModel: GameViewModel())
//}
