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
                Image("main_logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .align(.trailing)
                    

                contentView()
                    .padding(.leading, 40)
                    .align(.top, .leading)
                // TODO: design a better approach
#if os(OSX)
                    .padding(.top, 70)
#endif
            }
            Spacer()
            MenuFooterView()
        }
        .padding()
        .fadeIn()
    }
    
    private func contentView() -> some View {
        let callback = flow.handle(action:)
        
        let dataSource: MenuPageDataSource = switch flow.route {
        case .landing:
            LandingPageDataSource(callback: callback)
        case .gameOver(let stats):
            GameOverPageDataSource(isWinner: stats.isWinner, callback: callback)
        case .options:
            OptionsPageDataSource(callback: callback)
        case .pause:
            PausePageDataSource(callback: callback)
        }
        return MenuPageListView(dataSource: dataSource)
    }
}

struct MenuHeaderView: View {
    @Environment(\.themeProvider) var themeProvider
    let title: String
    
    var body: some View {
        Text(title.uppercased())
            .font(.system(size: 55))
            .foregroundStyle(themeProvider.menuHeader)
            .shadow(color: themeProvider.commonShadow, radius: 12)
    }
}

struct MenuFooterView: View {
    @Environment(\.themeProvider) var themeProvider
    var body: some View {
        HStack {
            Button(
                action: {},
                label: {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundStyle(.red)
                        Text("Support project")
                            .foregroundStyle(themeProvider.menuFooterText)
                    }
                }
            )
            Spacer()
            Text("Version 0.1")
                .foregroundStyle(themeProvider.menuFooterText)
        }
    }
}

#Preview {
    MenuView(flow: MenuFlow(route: .landing))
}
