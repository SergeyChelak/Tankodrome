//
//  HudView+StatsOverlayView.swift
//  Tankodrome
//
//  Created by Sergey on 01.03.2025.
//

import SwiftUI

extension HudView {
    struct StatsOverlayView: View {
        let text: String
        
        var body: some View {
            VStack {
                HStack {
                    Text(text)
                        .font(.title)
                        .shadow(color: .black, radius: 2)
                    Spacer()
                }
                Spacer()
            }
            .padding()
        }
    }
}
