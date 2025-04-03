//
//  GameView.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import SwiftUI
import SpriteKit

struct GameView: View {
#if os(iOS)
    private let controller = VirtualController()
#endif
    @StateObject
    var viewModel: GameViewModel

    var body: some View {
        GeometryReader { proxy in
            contentView(proxy.size)
        }
    }
    
    private func contentView(_ size: CGSize) -> some View {
        ZStack {
            SpriteView(
                scene: viewModel.scene(with: size),
                options: [.ignoresSiblingOrder],
                debugOptions: [.showsFPS, .showsPhysics, .showsNodeCount]
            )
            .ignoresSafeArea()
            .task {
                await viewModel.load()
            }
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
            HudView(hud: viewModel.hudModel)
        }
        .opacity(viewModel.opacity)
    }
}

//#Preview {
//    GameView(viewModel: GameViewModel())
//}
