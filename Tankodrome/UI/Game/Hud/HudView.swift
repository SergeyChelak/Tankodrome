//
//  HudView.swift
//  Tankodrome
//
//  Created by Sergey on 01.03.2025.
//

import SwiftUI

func composeHudView(_ gameFlow: GameFlow) -> some View {
    let viewModel = HudViewModel(gameFlow: gameFlow)
    return HudView(viewModel: viewModel)
}

struct HudView: View {
    @StateObject
    var viewModel: HudViewModel
    
    var body: some View {
        ZStack {
            Text(viewModel.healthText)
                .font(.largeTitle)
                .shadow(color: .black, radius: 2.0)
                .align(.leading, .top)
            
            // TODO: iOS only
            Image(systemName: "pause.circle.fill")
                .font(.largeTitle)
                .shadow(color: .black, radius: 2.0)
                .onTapGesture(perform: viewModel.onPauseTap)
                .align(.top, .trailing)
        }
        .padding()
    }
}
