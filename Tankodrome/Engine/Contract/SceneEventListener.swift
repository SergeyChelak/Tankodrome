//
//  SceneEventListener.swift
//  Tankodrome
//
//  Created by Sergey on 04.04.2025.
//

import Foundation

protocol SceneEventListener {
    func onUpdate()
    func onDidSimulatePhysics()
    func onDidFinishUpdate()
}
