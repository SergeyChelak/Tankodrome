//
//  MenuView.swift
//  Tankodrome
//
//  Created by Sergey on 05.04.2025.
//

import SwiftUI

struct MenuView: View {
    @StateObject
    var flow: MenuFlow
    
    var body: some View {
        VStack {
            MenuHeaderView(title: "tankodrome")
                .align(.leading)
            Spacer()
            ZStack {
                contentView()
                    .align(.leading)
                
                Image("main_logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .align(.trailing)
            }
            Spacer()
            MenuFooterView()
        }
        .padding()
        .fadeIn()
    }
    
    @ViewBuilder
    private func contentView() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Play")
            Text("Continue")
            Text("Options")
            Text("")
            Text("Exit")
        }
        .font(.system(size: 35))
        .padding(.leading, 40)
    }
}

struct MenuHeaderView: View {
    let title: String
    
    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 55))
            .foregroundStyle(.white)
            .shadow(color: .black, radius: 12)
    }
}

struct MenuFooterView: View {
    var body: some View {
        HStack {
            Button(
                action: {},
                label: {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                        Text("Support project")
                    }
                }
            )
            Spacer()
            Text("Version 0.1")
        }
    }
}

#Preview {
    MenuView(flow: MenuFlow())
}
