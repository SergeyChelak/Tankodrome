//
//  HudViewModel.swift
//  Tankodrome
//
//  Created by Sergey on 01.03.2025.
//

import Foundation

typealias ActionCallback = (HudAction) -> Void

protocol HudViewModel: ObservableObject {
    var state: GameState { get }
    var healthText: String { get }
    var actionCallback: ActionCallback { get }
}
