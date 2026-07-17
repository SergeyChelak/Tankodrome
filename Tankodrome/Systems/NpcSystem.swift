//
//  NpcSystem.swift
//  Tankodrome
//
//  Created by Sergey on 26.02.2025.
//

import Foundation
import SpriteKit

/// Drives every NPC tank through a lightweight finite state machine
/// (patrol → chase → search → attack) built on occlusion-correct perception,
/// grid navigation, a clear-shot firing gate (which prevents both wall-shots and
/// friendly fire), and simple squad coordination. Everything is perception- and
/// grid-based — a handful of rays plus a throttled A* per NPC — so it stays cheap.
final class NpcSystem: System {
    // Perception
    private let halfFOV: CGFloat
    private let squareVisionRange: CGFloat
    private let visionRange: CGFloat
    // Combat
    private let squareAttackRange: CGFloat
    private let aimTolerance: CGFloat
    private let aimHoldDuration: TimeInterval
    // Memory / navigation
    private let memoryDuration: TimeInterval
    private let repathInterval: TimeInterval

    // Tuning constants (steering feel).
    private let patrolSpeedFactor: CGFloat = 0.25
    private let chaseSpeedFactor: CGFloat = 0.7
    private let moveTurnThreshold: CGFloat = 0.08   // rad — deadband before we bother steering
    private let pivotTurnThreshold: CGFloat = 0.8   // rad — turn sharper than this ⇒ pivot in place
    private let avoidanceProbeFactor: CGFloat = 1.8 // whisker length in tank-sizes
    private let avoidanceSpread: CGFloat = 0.5      // rad — side whisker angle

    private var nextFlankSlot = 0

    public init(
        fieldOfView: CGFloat,
        visionRange: CGFloat,
        attackDistance: CGFloat,
        aimTolerance: CGFloat = 0.12,
        aimHoldDuration: TimeInterval = 0.25,
        memoryDuration: TimeInterval = 4.0,
        repathInterval: TimeInterval = 0.6
    ) {
        self.halfFOV = fieldOfView * 0.5
        self.visionRange = visionRange
        self.squareVisionRange = visionRange.sqr()
        self.squareAttackRange = attackDistance.sqr()
        self.aimTolerance = aimTolerance
        self.aimHoldDuration = aimHoldDuration
        self.memoryDuration = memoryDuration
        self.repathInterval = repathInterval
    }

    func onUpdate(context: any GameSceneContext) {
        let deltaTime = context.deltaTime
        let nav = context.getComponent(of: NavGridComponent.self)?.value
        let squad = context.getComponent(of: SquadComponent.self)
        let target = context.sprites.first { $0.hasComponent(of: PlayerMarker.self) }

        // Age the shared squad memory once per frame, before any NPC refreshes it.
        squad?.age(by: deltaTime, forgetAfter: memoryDuration)

        for npc in context.sprites where npc.hasComponent(of: NpcMarker.self) {
            guard let brain = brain(for: npc) else {
                continue
            }
            resetControllerState(for: npc)
            think(
                npc: npc,
                brain: brain,
                target: target,
                nav: nav,
                squad: squad,
                deltaTime: deltaTime,
                context: context
            )
        }
    }

    // MARK: - Brain lifecycle

    private func brain(for npc: Sprite) -> AiComponent? {
        if let existing = npc.getComponent(of: AiComponent.self) {
            return existing
        }
        let brain = AiComponent()
        brain.flankSlot = nextFlankSlot
        brain.isRegistered = true
        brain.repathTimer = TimeInterval(nextFlankSlot % 8) * 0.05 // desync repaths
        nextFlankSlot += 1
        npc.addComponent(brain)
        return brain
    }

    private func resetControllerState(for sprite: Sprite) {
        guard let controller = sprite.getComponent(of: ControllerComponent.self) else {
            return
        }
        controller.value.isAcceleratePressed = false
        controller.value.isDeceleratePressed = false
        controller.value.isShootPressed = false
        controller.value.isTurnLeftPressed = false
        controller.value.isTurnRightPressed = false
    }

    // MARK: - Decision

    private func think(
        npc: Sprite,
        brain: AiComponent,
        target: Sprite?,
        nav: NavGrid?,
        squad: SquadComponent?,
        deltaTime: TimeInterval,
        context: GameSceneContext
    ) {
        let canSeeTarget = target.map { canSee($0, from: npc, context: context) } ?? false

        if canSeeTarget, let target {
            brain.lastKnownTargetPosition = target.position
            brain.memoryTimer = memoryDuration
            squad?.reportContact(at: target.position)
            brain.state = .attack
        } else {
            brain.memoryTimer -= deltaTime
            // Fall back to the squad's shared sighting if we have none of our own.
            if brain.lastKnownTargetPosition == nil, let shared = squad?.targetMemory {
                brain.lastKnownTargetPosition = shared.position
                brain.memoryTimer = max(brain.memoryTimer, memoryDuration - shared.age)
            }
            if brain.memoryTimer > 0, let goal = brain.lastKnownTargetPosition {
                brain.state = reached(goal, by: npc) ? .search : .chase
            } else {
                brain.lastKnownTargetPosition = nil
                brain.state = .patrol
            }
        }

        if brain.state != .attack {
            brain.aimHoldTime = 0
        }

        switch brain.state {
        case .attack: attack(npc: npc, brain: brain, target: target, deltaTime: deltaTime, context: context)
        case .chase:  chase(npc: npc, brain: brain, nav: nav, deltaTime: deltaTime, context: context)
        case .search: search(npc: npc)
        case .patrol: patrol(npc: npc, brain: brain, nav: nav, deltaTime: deltaTime, context: context)
        }
    }

    // MARK: - States

    private func attack(
        npc: Sprite,
        brain: AiComponent,
        target: Sprite?,
        deltaTime: TimeInterval,
        context: GameSceneContext
    ) {
        guard let target,
              let controller = npc.getComponent(of: ControllerComponent.self),
              let velocity = npc.getComponent(of: VelocityComponent.self) else {
            return
        }
        let toTarget = target.position - npc.position
        let squareDistance = toTarget.squaredDistance()

        if squareDistance > squareAttackRange {
            // Close the distance, steering around any walls on the way.
            steerWithAvoidance(npc: npc, toward: target.position, speedFactor: chaseSpeedFactor, context: context)
        } else {
            // In range: hold position and aim precisely at the target.
            velocity.value *= 0.9
            aim(npc: npc, at: target.position, controller: controller)
        }

        // Firing gate — shared by both branches. Only fire when the aim has settled
        // AND the muzzle line is genuinely clear onto the target (no wall, no ally).
        let aimDiff = npc.zRotation.signedAngleDifference(toTarget.atan2()).abs()
        if aimDiff <= aimTolerance {
            brain.aimHoldTime += deltaTime
            let requiredHold = aimHoldDuration + TimeInterval(brain.flankSlot % 3) * 0.08
            if brain.aimHoldTime >= requiredHold,
               hasClearShot(from: npc, to: target, context: context) {
                controller.value.isShootPressed = true
            }
        } else {
            brain.aimHoldTime = 0
        }
    }

    private func chase(
        npc: Sprite,
        brain: AiComponent,
        nav: NavGrid?,
        deltaTime: TimeInterval,
        context: GameSceneContext
    ) {
        guard let goal = brain.lastKnownTargetPosition else {
            return
        }
        // While still far, spread onto a flank so the squad approaches from several
        // sides instead of stacking single-file into each other's line of fire.
        let approach = flankedGoal(goal, npc: npc, brain: brain, nav: nav)
        navigate(npc: npc, brain: brain, to: approach, nav: nav, speedFactor: chaseSpeedFactor, deltaTime: deltaTime, context: context)
    }

    private func search(npc: Sprite) {
        guard let controller = npc.getComponent(of: ControllerComponent.self),
              let velocity = npc.getComponent(of: VelocityComponent.self) else {
            return
        }
        // Arrived at the last-known position with no line of sight: rotate to scan.
        velocity.value *= 0.9
        controller.value.isTurnLeftPressed = true
    }

    private func patrol(
        npc: Sprite,
        brain: AiComponent,
        nav: NavGrid?,
        deltaTime: TimeInterval,
        context: GameSceneContext
    ) {
        guard let nav else {
            // No navigation grid: creep forward and let whisker avoidance steer.
            steerWithAvoidance(npc: npc, toward: pointAhead(from: npc, distance: 200), speedFactor: patrolSpeedFactor, context: context)
            return
        }
        if brain.wanderGoal == nil || reached(brain.wanderGoal!, by: npc) {
            brain.wanderGoal = randomWalkablePoint(near: npc.position, nav: nav)
            brain.path = []
        }
        guard let wander = brain.wanderGoal else {
            return
        }
        navigate(npc: npc, brain: brain, to: wander, nav: nav, speedFactor: patrolSpeedFactor, deltaTime: deltaTime, context: context)
    }

    // MARK: - Perception

    /// Occlusion-correct line of sight: the target must be in range, within the FOV
    /// cone, and the nearest body along the ray must actually be the target.
    private func canSee(_ target: Sprite, from npc: Sprite, context: GameSceneContext) -> Bool {
        let toTarget = target.position - npc.position
        guard toTarget.squaredDistance() <= squareVisionRange else {
            return false
        }
        let angleDiff = npc.zRotation.signedAngleDifference(toTarget.atan2()).abs()
        guard angleDiff <= halfFOV else {
            return false
        }
        return context.nearestHit(from: npc.position, to: target.position, excluding: npc) === target
    }

    /// The muzzle ray's first solid hit must be the target — otherwise a wall,
    /// obstacle, or allied tank is in the way and we hold fire.
    private func hasClearShot(from npc: Sprite, to target: Sprite, context: GameSceneContext) -> Bool {
        let facing = npc.zRotation
        let muzzleOffset = npc.size.height * 0.5 * 1.5 // matches projectile spawn offset
        let muzzle = pointAhead(from: npc, distance: muzzleOffset)
        let end = muzzle + CGPoint.rotated(radians: facing) * visionRange
        return context.nearestHit(from: muzzle, to: end, excluding: npc) === target
    }

    // MARK: - Steering / navigation

    private func navigate(
        npc: Sprite,
        brain: AiComponent,
        to goal: CGPoint,
        nav: NavGrid?,
        speedFactor: CGFloat,
        deltaTime: TimeInterval,
        context: GameSceneContext
    ) {
        guard let nav else {
            steerWithAvoidance(npc: npc, toward: goal, speedFactor: speedFactor, context: context)
            return
        }
        brain.repathTimer -= deltaTime
        let goalCell = nav.cell(at: goal)
        if brain.path.isEmpty || brain.repathTimer <= 0 || brain.pathGoalCell != goalCell {
            brain.path = nav.findPath(from: npc.position, to: goal)
            brain.pathIndex = 0
            brain.pathGoalCell = goalCell
            brain.repathTimer = repathInterval
        }
        let reachSq = (0.6 * Swift.min(nav.tileSize.width, nav.tileSize.height)).sqr()
        while brain.pathIndex < brain.path.count,
              npc.position.squaredDistance(to: brain.path[brain.pathIndex]) < reachSq {
            brain.pathIndex += 1
        }
        let waypoint = brain.pathIndex < brain.path.count ? brain.path[brain.pathIndex] : goal
        steerWithAvoidance(npc: npc, toward: waypoint, speedFactor: speedFactor, context: context)
    }

    /// Turns toward `point`, but if a wall is close ahead, overrides the heading to
    /// steer around it. Speed is written directly (pivots in place for sharp turns).
    private func steerWithAvoidance(
        npc: Sprite,
        toward point: CGPoint,
        speedFactor: CGFloat,
        context: GameSceneContext
    ) {
        guard let controller = npc.getComponent(of: ControllerComponent.self),
              let velocity = npc.getComponent(of: VelocityComponent.self) else {
            return
        }
        let desired = (point - npc.position).atan2()
        let heading = avoidanceHeading(for: npc, context: context) ?? desired
        applyMovement(npc: npc, controller: controller, velocity: velocity, heading: heading, speedFactor: speedFactor)
    }

    private func applyMovement(
        npc: Sprite,
        controller: ControllerComponent,
        velocity: VelocityComponent,
        heading: CGFloat,
        speedFactor: CGFloat
    ) {
        let diff = npc.zRotation.signedAngleDifference(heading)
        if diff.abs() > moveTurnThreshold {
            if diff > 0 {
                controller.value.isTurnRightPressed = true
            } else {
                controller.value.isTurnLeftPressed = true
            }
        }
        // Pivot in place for sharp turns; otherwise drive at the requested pace.
        velocity.value = diff.abs() > pivotTurnThreshold ? 0 : speedFactor * velocity.limit
    }

    private func aim(npc: Sprite, at point: CGPoint, controller: ControllerComponent) {
        let diff = npc.zRotation.signedAngleDifference((point - npc.position).atan2())
        guard diff.abs() > aimTolerance else {
            return
        }
        if diff > 0 {
            controller.value.isTurnRightPressed = true
        } else {
            controller.value.isTurnLeftPressed = true
        }
    }

    /// If a wall is within the forward whisker, returns a heading that steers toward
    /// the clearer side; otherwise `nil` (path is clear).
    private func avoidanceHeading(for npc: Sprite, context: GameSceneContext) -> CGFloat? {
        let facing = npc.zRotation
        let probe = avoidanceProbeFactor * npc.size.width.max(npc.size.height)
        func blocked(_ angle: CGFloat) -> Bool {
            let end = npc.position + CGPoint.rotated(radians: angle) * probe
            guard let hit = context.nearestHit(from: npc.position, to: end, excluding: npc) else {
                return false
            }
            return isWall(hit)
        }
        guard blocked(facing) else {
            return nil
        }
        let leftBlocked = blocked(facing + avoidanceSpread)
        let rightBlocked = blocked(facing - avoidanceSpread)
        if rightBlocked && !leftBlocked {
            return facing + avoidanceSpread * 2
        }
        if leftBlocked && !rightBlocked {
            return facing - avoidanceSpread * 2
        }
        // Boxed in (or symmetric): make a hard turn to break away.
        return facing + .pi * 0.5
    }

    // MARK: - Coordination

    /// Offsets the goal perpendicular to the approach so squad members spread out.
    /// Only applied while still far away; up close everyone converges on the target.
    private func flankedGoal(_ goal: CGPoint, npc: Sprite, brain: AiComponent, nav: NavGrid?) -> CGPoint {
        guard brain.flankSlot > 0 else {
            return goal
        }
        let toGoal = goal - npc.position
        let spacing = nav.map { 1.5 * $0.tileSize.width } ?? 160
        let flankRange = (spacing * 4).sqr()
        guard toGoal.squaredDistance() > flankRange else {
            return goal
        }
        let side: CGFloat = (brain.flankSlot % 2 == 1) ? 1 : -1
        let magnitude = CGFloat((brain.flankSlot + 1) / 2) * spacing
        let perpendicular = toGoal.atan2() + side * (.pi * 0.5)
        return goal + CGPoint.rotated(radians: perpendicular) * magnitude
    }

    // MARK: - Helpers

    private func reached(_ point: CGPoint, by npc: Sprite) -> Bool {
        let threshold = (1.5 * npc.size.width.max(npc.size.height)).sqr()
        return npc.position.squaredDistance(to: point) < threshold
    }

    private func pointAhead(from npc: Sprite, distance: CGFloat) -> CGPoint {
        npc.position + CGPoint.rotated(radians: npc.zRotation) * distance
    }

    private func randomWalkablePoint(near origin: CGPoint, nav: NavGrid) -> CGPoint? {
        for _ in 0..<12 {
            let col = Int.random(in: 0..<max(1, nav.cols))
            let row = Int.random(in: 0..<max(1, nav.rows))
            let cell = NavGrid.Cell(row: row, col: col)
            if nav.isWalkable(cell) {
                return nav.center(of: cell)
            }
        }
        return nil
    }

    private func isWall(_ sprite: Sprite) -> Bool {
        sprite.hasComponent(of: BorderMarker.self) || sprite.hasComponent(of: ObstacleMarker.self)
    }
}
