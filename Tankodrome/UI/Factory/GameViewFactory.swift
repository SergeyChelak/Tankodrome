//
//  GameViewFactory.swift
//  Tankodrome
//
//  Created by Sergey on 03.04.2025.
//

import Foundation

protocol GameViewFactory {
    func gameView(flow: GameFlow) -> ViewHolder
    
    func menuView(flow: MenuFlow) -> ViewHolder
}
