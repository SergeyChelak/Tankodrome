//
//  MenuView.swift
//  Tankodrome
//
//  Created by Sergey on 05.04.2025.
//

import SwiftUI

struct MenuView: View {
    private let menuViewFactory: MenuViewFactory
    @ObservedObject
    private var flow: MenuFlow
    private let sfx: MenuSFXPlayer
    
    init(
        menuViewFactory: MenuViewFactory,
        flow: MenuFlow,
        audioPlaybackService: AudioPlaybackService
    ) {
        self.menuViewFactory = menuViewFactory
        self._flow = ObservedObject(wrappedValue: flow)
        self.sfx = MenuSFXPlayer(service: audioPlaybackService)
    }
    
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
                menuViewFactory.menuView(
                    for: flow.route,
                    parentRoute: flow.prevRoute,
                    callback: flow.handle(action:)
                )
                .view
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
        .onAppear {
            sfx.start(flow.route)
        }
        .onDisappear {
            sfx.stop()
        }
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
    let settings = composeAppSettings()
    let factory = MenuViewFactory(
        inputController: InputController(),
        settings: settings
    )
    let flow = MenuFlow(route: .landing)
    return MenuView(
        menuViewFactory: factory,
        flow: flow,
        audioPlaybackService: composeAudioService()
    )
}
