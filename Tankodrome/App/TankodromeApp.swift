//
//  TankodromeApp.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import SwiftUI

@main
struct TankodromeApp: App {
    @StateObject
    private var viewModel: TankodromeAppViewModel
    private let viewFactory: AppViewFactory
    
    init() {
        let inputController = InputController()
        let settings = composeAppSettings()
        let menuViewFactory = MenuViewFactory(
            inputController: inputController,
            settings: settings
        )
        let gameViewFactory = GameViewFactory(
            inputController: inputController,
            menuViewFactory: menuViewFactory
        )
        self.viewFactory = AppViewFactory(
            gameViewFactory: gameViewFactory
        )
        let audioService = AudioService(
            maxSfxChannels: 16,
            sfxVolume: 0.6,
            musicVolume: 0.6
        )
        let viewModel = TankodromeAppViewModel(
            appSettings: settings,
            audioService: audioService
        )
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some Scene {
        WindowGroup {
            contentView.view
            .task {
                await viewModel.load()
            }
#if os(OSX)
            .onDisappear {
                NSApplication.shared.terminate(nil)
            }
#endif
        }
    }
    
    private var contentView: ViewHolder {
        switch viewModel.state {
        case .loading:
            viewFactory.loadingView()
        case .failed(let error):
            viewFactory.errorView(error)
        case .ready(let appContext):
            viewFactory.rootView(appContext)
        }
    }
}
