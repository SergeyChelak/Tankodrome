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
            GameOverView(state: hud.state)
            StatsOverlayView(text: hud.healthText)
        }
        .padding()
    }
}

#Preview {
    let hud = HudModel()
    return HudView(hud: hud)
}
