//
//  MenuFlow.swift
//  Tankodrome
//
//  Created by Sergey on 05.04.2025.
//

import Foundation

final class MenuFlow: ObservableObject {
    enum State {
        case landing
        case gameOver
        case pause
    }
    
    private(set) var state: State = .landing
}
