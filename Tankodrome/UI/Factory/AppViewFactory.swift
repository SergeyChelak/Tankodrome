//
//  AppViewFactory.swift
//  Tankodrome
//
//  Created by Sergey on 03.04.2025.
//

import SwiftUI

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
