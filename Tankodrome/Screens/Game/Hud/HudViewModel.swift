//
//  HudViewModel.swift
//  Tankodrome
//
//  Created by Sergey on 01.03.2025.
//

import Foundation

protocol HudViewModel: ObservableObject {
    var state: GameState { get }
    var healthText: String { get }
}
