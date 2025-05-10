//
//  ThemeProvider.swift
//  Tankodrome
//
//  Created by Sergey on 11.05.2025.
//

import Foundation
import SwiftUI

final class ThemeProvider {
    // common
    var commonShadow: Color {
        .black
    }
    
    // menu
    var menuHeader: Color {
        menuPrimaryColor
    }
    
    var menuSectionTitle: Color {
        menuPrimaryColor
    }
    
    var menuDivider: Color {
        menuPrimaryColor
    }
    
    var menuClickableItem: Color {
        menuPrimaryColor
    }
    
    var menuFooterText: Color {
        menuPrimaryColor
    }
    
    var hudButtonTint: Color {
        .white
    }
    
    
    // --- end of interface
    var menuPrimaryColor: Color {
        .white
    }
}

extension EnvironmentValues {
  @Entry var themeProvider: ThemeProvider = .init()
}
