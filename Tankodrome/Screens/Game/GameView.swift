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
    // TODO: inverse dependency
    @StateObject
    var viewModel = GameViewModel()
    
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
                viewModel.load()
            }
#if os(OSX)
            .onKeyPress(phases: .all) { press in
                viewModel.onKeyPress(press)
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

#Preview {
    GameView()
}
