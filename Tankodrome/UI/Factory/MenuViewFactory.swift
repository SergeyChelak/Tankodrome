//
//  MenuViewFactory.swift
//  Tankodrome
//
//  Created by Sergey on 23.05.2025.
//

import Foundation

final class MenuViewFactory {
    private let settings: AppSettings
    
    init(settings: AppSettings) {
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
        let viewModel = MenuPageListViewModel(dataSource: dataSource)
        let view = MenuPageListView(viewModel: viewModel)
        return ViewHolder(view)
    }
}
