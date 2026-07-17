//
//  NavGridComponent.swift
//  Tankodrome
//
//  Created by Sergey on 17.07.2026.
//

import Foundation

/// Scene-level component carrying the level's navigation grid so the NPC AI can
/// path around walls. Built once in `LevelComposer` and read via
/// `context.getComponent(of: NavGridComponent.self)`.
final class NavGridComponent: ValueWrapper<NavGrid>, Component { }
