//
//  MenuViewFactory.swift
//  Tankodrome
//
//  Created by Sergey on 23.05.2025.
//

import Foundation

final class MenuViewFactory {
    private let inputController: InputController
    private let settings: AppSettings
    
    init(
        inputController: InputController,
        settings: AppSettings
    ) {
        self.inputController = inputController
        self.settings = settings
    }
    
    func menuView(
        for route: MenuFlow.Route,
        callback: @escaping MenuActionCallback
    ) -> ViewHolder {
        let dataSource: MenuPageDataSource = switch route {
        case .landing:
            LandingPageDataSource(callback: callback)
        case .gameOver(let stats):
            GameOverPageDataSource(isWinner: stats.isWinner, callback: callback)
        case .options:
            OptionsPageDataSource(callback: callback)
        case .pause:
            PausePageDataSource(callback: callback)
        }
        let viewModel = MenuPageListViewModel(
            inputController: inputController,
            dataSource: dataSource
        )
        let view = MenuPageListView(viewModel: viewModel)
        return ViewHolder(view)
    }
}
