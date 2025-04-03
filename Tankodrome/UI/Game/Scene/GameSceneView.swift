//
//  GameSceneView.swift
//  Tankodrome
//
//  Created by Sergey on 03.04.2025.
//

import SpriteKit
import SwiftUI

func composeGameScene(_ gameFlow: GameFlow) -> some View {
    let viewModel = GameSceneViewModel(gameFlow: gameFlow)
    return GameSceneView(viewModel: viewModel)
}

struct GameSceneView: View {
#if os(iOS)
    private let controller = VirtualController()
#endif
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
#if os(OSX)
        .onKeyPress(phases: .all) { press in
            viewModel.onKeyPress(press)
            return .handled
        }
        .setFocused()
#endif
#if os(iOS)
        .onAppear {
            controller.connect(to: viewModel)
        }
        .onDisappear {
            controller.disconnect()
        }
#endif
    }
}

//#Preview {
//    GameSceneView()
//}
