//
//  MainMenuView.swift
//  Tankodrome
//
//  Created by Sergey on 01.03.2025.
//

import SwiftUI

struct MainMenuView: View {
    let handler: MainMenuHandler?
    
    var body: some View {
        VStack {
            Text("Tankodrome".uppercased())
                .font(.largeTitle)
                .foregroundStyle(.white)
                .shadow(radius: 12)
                .padding(.top)
            Image("main_logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            HStack {
                Image(systemName: "play.circle.fill")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .shadow(radius: 12)
                Text("Play")
                    .font(.largeTitle)
                    .foregroundStyle(.white)
                    .shadow(radius: 12)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                handler?.play()
            }
            .shadow(radius: 5)
            .padding(.bottom)
        }
    }
}

#Preview {
    MainMenuView(handler: nil)
}
