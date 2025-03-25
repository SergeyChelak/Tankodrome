//
//  TankodromeApp.swift
//  Tankodrome
//
//  Created by Sergey on 23.02.2025.
//

import SwiftUI

@main
struct TankodromeApp: App {
    @StateObject
    var flow = TankodromeFlow(factory: TankodromeViewFactory())
    
    var body: some Scene {
        WindowGroup {
            flow.activeViewHolder.view
#if os(OSX)
                .onDisappear {
                    NSApplication.shared.terminate(nil)
                }
#endif
        }
    }
}
