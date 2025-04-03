//
//  AppState.swift
//  Tankodrome
//
//  Created by Sergey on 03.04.2025.
//

import Foundation

enum AppState {
    case loading
    case failed(Error)
    case ready(AppContext)
}
