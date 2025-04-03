//
//  HudView+GameOverView.swift
//  Tankodrome
//
//  Created by Sergey on 01.03.2025.
//

import Foundation
import SwiftUI

extension HudView {
    struct GameOverView: View {
        let state: GameState
        let callback: ActionCallback
        
        var body: some View {
            switch state {
            case .win:
                StateOverlayView(
                    text: "You won!",
                    actions: [.replay, .nextLevel],
                    callback: callback
                )
            case .lose:
                StateOverlayView(
                    text: "Game Over",
                    actions: [.replay],
                    callback: callback
                )
            case .play:
                EmptyView()
            }
            
        }
    }
    
    struct StateOverlayView: View {
        let text: String
        let actions: [HudAction]
        let callback: ActionCallback
        
        var body: some View {
            VStack {
                Text(text)
                    .font(.largeTitle)
                    .shadow(color: .black, radius: 2)
                HStack(spacing: 50) {
                    ForEach(actions.indices, id: \.self) { i in
                        let action = actions[i]
                        ActionButton(caption: action.uiName) {
                            callback(action)
                        }
                    }
                }
                .padding()
            }
        }
    }
    
    struct ActionButton: View {
        let caption: String
        let action: () -> Void
        
        var body: some View {
            Button {
                action()
            } label: {
                Text(caption)
                    .font(.title)
            }
        }
    }
}

#Preview {
    HudView<HudModel>.StateOverlayView(
        text: "Hello!",
        actions: [.replay, .nextLevel],
        callback: { _ in }
    )
}
