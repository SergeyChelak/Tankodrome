//
//  AppSettings.swift
//  Tankodrome
//
//  Created by Sergey on 24.05.2025.
//

import Foundation
import Combine

func composeAppSettings() -> AppSettings {
    let provider = SettingsProvider()
    return AppSettings(provider: provider)
}


final class AppSettings {
    enum Setting {
        case sfx, music
    }

    private let provider: SettingsProvider
    private let subject = PassthroughSubject<Setting, Never>()
    
    var publisher: AnyPublisher<Setting, Never> {
        subject.eraseToAnyPublisher()
    }
        
    init(provider: SettingsProvider) {
        self.provider = provider
    }
    
    var sfxEnabled: Bool {
        get {
            provider.sfxEnabled
        }
        set {
            provider.sfxEnabled = newValue
            subject.send(.sfx)
        }
    }
    
    var musicEnabled: Bool {
        get {
            provider.musicEnabled
        }
        set {
            provider.musicEnabled = newValue
            subject.send(.music)
        }
    }
}

