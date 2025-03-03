//
//  HudView.swift
//  Tankodrome
//
//  Created by Sergey on 01.03.2025.
//

import SwiftUI

struct HudView<T: HudViewModel>: View {
    @ObservedObject
    var hud: T
    
    var body: some View {
        ZStack {
            GameOverView(state: hud.state, callback: hud.actionCallback)
            StatsOverlayView(text: hud.healthText)
        }
        .padding()
    }
}

#Preview {
    let hud = HudModel(actionCallback: { _ in })
    return HudView(hud: hud)
}
