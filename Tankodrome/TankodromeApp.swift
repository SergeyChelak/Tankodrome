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
    private var viewModel = TankodromeAppViewModel()
    
    private let viewFactory = AppViewFactory()
    
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
            viewFactory.gameView(appContext)
        }
    }
}

enum AppState {
    case loading
    // error message
    case failed(Error)
    case ready(AppContext)
}

struct AppContext {
    let gameFlow: GameFlow
}

struct AppViewFactory {
    func loadingView() -> ViewHolder {
        let view = Text("Loading")
        return ViewHolder(view)
    }
    
    func errorView(_ error: Error) -> ViewHolder {
        let view = Text(error.localizedDescription)
        return ViewHolder(view)
    }
    
    func gameView(_ context: AppContext) -> ViewHolder {
        let viewModel = RootViewModel(context)
        let view = RootView(viewModel: viewModel)
        return ViewHolder(view)
    }
}

fileprivate final class TankodromeAppViewModel: ObservableObject {
    @Published
    private(set) var state: AppState = .loading
    
    func load() async {
        do {
            let gameFlow = try composeGameFlow()
            await handle(gameFlow)
        } catch {
            await handleError(error)
        }
    }
    
    @MainActor
    private func handle(_ gameFlow: GameFlow) async {
        let context = AppContext(
            gameFlow: gameFlow
        )
        self.state = .ready(context)
    }
    
    @MainActor
    private func handleError(_ error: Error) async {
        self.state = .failed(error)
    }
}
