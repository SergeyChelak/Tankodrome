//
//  NSWindow+Styling.swift
//  Tankodrome
//
//  Created by Sergey on 12.11.2025.
//

#if os(OSX)
import AppKit

extension NSWindow {
    func hideAllElements() {
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        self.lightTrafficButtonsVisible(false)
    }
    
    func lightTrafficButtonsVisible(_ isVisible: Bool) {
        let buttons: [NSWindow.ButtonType] = [
            .closeButton,
            .zoomButton,
            .miniaturizeButton
        ]
        buttons
            .compactMap { standardWindowButton($0) }
            .forEach { $0.isHidden = !isVisible }
    }
}
#endif
