//
//  SquadComponent.swift
//  Tankodrome
//
//  Created by Sergey on 17.07.2026.
//

import Foundation

/// Scene-level blackboard shared by the enemy squad. When one NPC sees the target
/// it reports the position here; allies without direct line-of-sight read it to
/// converge on the target instead of idling. Near-zero cost — a single record
/// updated once per frame.
final class SquadComponent: Component {
    struct TargetMemory {
        var position: CGPoint
        /// Seconds since the target was last actually seen (0 == fresh this frame).
        var age: TimeInterval
    }

    private(set) var targetMemory: TargetMemory?

    /// Called by any NPC that currently has line-of-sight to the target.
    func reportContact(at position: CGPoint) {
        targetMemory = TargetMemory(position: position, age: 0)
    }

    /// Ages the shared memory and forgets it after `forgetAfter` seconds without
    /// a fresh contact.
    func age(by deltaTime: TimeInterval, forgetAfter: TimeInterval) {
        guard var memory = targetMemory else {
            return
        }
        memory.age += deltaTime
        targetMemory = memory.age > forgetAfter ? nil : memory
    }
}
