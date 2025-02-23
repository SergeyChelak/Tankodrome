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
    private let controller = makeVirtualController(nil)
#endif
    var body: some View {
        GeometryReader { proxy in
            contentView(proxy.size)
        }
    }
    
    private func contentView(_ size: CGSize) -> some View {
        ZStack {
            SpriteView(
                scene: makeScene(size),
                options: [.ignoresSiblingOrder],
                debugOptions: [.showsFPS, .showsPhysics, .showsNodeCount]
            )
            .ignoresSafeArea()
#if os(OSX)
            .onKeyPress(phases: .all) { press in
                // TODO: viewModel.onKeyPress(press)
                return .handled
            }
#endif
#if os(iOS)
            .onAppear {
                controller.connect()
            }
            .onDisappear {
                controller.disconnect()
            }
#endif
        }
    }
}

fileprivate func makeScene(_ size: CGSize) -> SKScene {
    let scene = GameScene()
    scene.size = size
    return scene
}

#Preview {
    GameView()
}
