//
//  TankodromeApp.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import SwiftUI

@main
struct TankodromeApp: App {
    var body: some Scene {
        WindowGroup {
            GameView()
#if os(OSX)
                .onDisappear {
                    NSApplication.shared.terminate(nil)
                }
#endif
        }
    }
}
