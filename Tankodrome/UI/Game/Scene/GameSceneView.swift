//
//  GameSceneView.swift
//  Tankodrome
//
//  Created by Sergey on 03.04.2025.
//

import SpriteKit
import SwiftUI

struct GameSceneView: View {
    @StateObject
    var viewModel: GameSceneViewModel
    
    var body: some View {
        GeometryReader { proxy in
            contentView(proxy.size)
        }
    }
    
    private func contentView(_ size: CGSize) -> some View {
        SpriteView(
            scene: viewModel.scene(with: size),
            options: [.ignoresSiblingOrder],
            debugOptions: [.showsFPS, .showsPhysics, .showsNodeCount]
        )
        .ignoresSafeArea()
        .onAppear {
            viewModel.onAppear()
        }
        .onDisappear {
            viewModel.onDisappear()
        }
    }
}

//#Preview {
//    GameSceneView()
//}
