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
        let audioService = composeAudioService()
        let menuViewFactory = MenuViewFactory(
            inputController: inputController,
            settings: settings
        )
        let gameViewFactory = GameViewFactory(
            inputController: inputController,
            menuViewFactory: menuViewFactory,
            audioPlaybackService: audioService
        )
        self.viewFactory = AppViewFactory(
            gameViewFactory: gameViewFactory
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
            .task {
                // suppress keyboard bell sound
                NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    // pass cmd + q to exit
                    if event.modifierFlags.contains(.command) && event.characters == "q" {
                        return event
                    }
                    return nil
                }
            }
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
