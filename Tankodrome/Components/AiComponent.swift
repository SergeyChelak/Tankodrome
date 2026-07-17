//
//  AiComponent.swift
//  Tankodrome
//
//  Created by Sergey on 17.07.2026.
//

import Foundation

/// Per-NPC "brain": the finite-state-machine state plus the memory and navigation
/// bookkeeping `NpcSystem` needs between frames.
final class AiComponent: Component {
    enum State {
        case patrol   // no target known — wander reachable ground
        case chase    // heading to the last-known target position
        case search   // arrived at last-known position, scanning around
        case attack   // target in sight — aim and fire through the clear-shot gate
    }

    var state: State = .patrol

    /// Where the target was last actually seen (own sighting or shared by the squad).
    var lastKnownTargetPosition: CGPoint?
    /// Counts down while the target is out of sight; when it hits zero the NPC
    /// forgets and returns to patrol.
    var memoryTimer: TimeInterval = 0

    // Navigation (cached A* path being followed).
    var path: [CGPoint] = []
    var pathIndex: Int = 0
    var repathTimer: TimeInterval = 0

    // Wedge detection: how long forward motion has been blocked, and the countdown
    // of an active escape (back-up-and-turn) maneuver.
    var stuckTimer: TimeInterval = 0
    var escapeTimer: TimeInterval = 0

    // Staggered decision throttle: time accumulated since this NPC last re-decided
    // its steering. Holding the command between decisions decorrelates mutual
    // reactions and prevents two NPCs livelocking against each other.
    var sinceDecision: TimeInterval = 0

    /// Current wander destination while patrolling.
    var wanderGoal: CGPoint?

    /// Stable squad slot used to spread NPCs onto different flank approaches and to
    /// desync their firing so they don't volley in unison.
    var flankSlot: Int = 0
    var isRegistered = false

    /// How long the aim has been continuously on-target; gates firing.
    var aimHoldTime: TimeInterval = 0
}
