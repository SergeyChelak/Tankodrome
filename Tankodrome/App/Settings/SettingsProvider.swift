//
//  SettingsProvider.swift
//  Tankodrome
//
//  Created by Sergey on 23.05.2025.
//

import Foundation

final class SettingsProvider {
    @UserDefault(key: "app.sound.sfx.enabled", defaultValue: true)
    var sfxEnabled: Bool
    
    @UserDefault(key: "app.sound.music.enabled", defaultValue: true)
    var musicEnabled: Bool
}

@propertyWrapper
struct UserDefault<Value> {
    let key: String
    let defaultValue: Value
    var container: UserDefaults = .standard

    var wrappedValue: Value {
        get {
            container.object(forKey: key) as? Value ?? defaultValue
        }
        set {
            container.set(newValue, forKey: key)
        }
    }
}
