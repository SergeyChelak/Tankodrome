//
//  HudView.swift
//  Tankodrome
//
//  Created by Sergey on 01.03.2025.
//

import SwiftUI

struct HudView: View {
    @Environment(\.themeProvider) var themeProvider
    @StateObject
    var viewModel: HudViewModel
    
    var body: some View {
        ZStack {
            HealthBarView(value: viewModel.healthPercentage)
                .align(.leading, .top)
            
            // TODO: iOS only
            Image(systemName: "pause.circle.fill")
                .font(.largeTitle)
                .foregroundStyle(themeProvider.hudButtonTint)
                .shadow(color: themeProvider.commonShadow, radius: 2.0)
                .onTapGesture(perform: viewModel.onPauseTap)
                .align(.top, .trailing)
        }
        .padding(5)
    }
}
