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
        self.viewFactory = AppViewFactory(gameViewFactory: gameViewFactory)
        self._viewModel = StateObject(wrappedValue: TankodromeAppViewModel(appSettings: settings))
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
