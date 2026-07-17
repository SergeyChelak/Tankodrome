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
            // .showsPhysics redraws every body outline each frame — on a generated
            // map with hundreds of contour bodies it costs real frame time and
            // makes the frame pacing (and therefore motion) visibly uneven.
            debugOptions: [.showsFPS, .showsNodeCount]
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
