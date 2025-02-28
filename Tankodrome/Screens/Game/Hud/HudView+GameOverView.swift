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
        
        var body: some View {
            switch state {
            case .win:
                StateOverlayView(text: "You won!")
            case .lose:
                StateOverlayView(text: "Game Over")
            case .play:
                EmptyView()
            }
            
        }
    }
    
    struct StateOverlayView: View {
        let text: String
        
        var body: some View {
            VStack {
                Text(text)
                    .font(.largeTitle)
                    .shadow(color: .black, radius: 2)
                // TODO: add replay & next level actions
            }
        }
    }
}
