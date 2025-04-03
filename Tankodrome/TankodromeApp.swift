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
            ZStack {
                Image("Ground_Tile_02_C")
                    .resizable(resizingMode: .tile)
                    .ignoresSafeArea()
                flow.activeViewHolder.view
            }            
#if os(OSX)
                .onDisappear {
                    NSApplication.shared.terminate(nil)
                }
#endif
        }
    }
}
