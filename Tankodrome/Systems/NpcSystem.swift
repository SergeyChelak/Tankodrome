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
    // Staggered movement decisions (seconds). Engaging NPCs override this and decide
    // every frame so their aim stays crisp.
    private let decisionInterval: TimeInterval = 0.06

    // Tuning constants (steering feel).
    private let patrolSpeedFactor: CGFloat = 0.25
    private let chaseSpeedFactor: CGFloat = 0.7
    private let minMoveSpeedFactor: CGFloat = 0.35  // speed kept while turning — no hard stop
    private let defaultRotationSpeed: CGFloat = 3.0 // fallback rad/s if a tank has none
    private let avoidanceProbeFactor: CGFloat = 2.2 // wall whisker length in tank-sizes
    private let avoidanceSpread: CGFloat = 0.6      // rad — side whisker angle
    private let separationRadiusFactor: CGFloat = 2.6 // NPC-NPC spacing in tank-sizes
    private let separationWeight: CGFloat = 1.7     // strength of anti-crowding push
    private let wallAvoidWeight: CGFloat = 1.5      // strength of the wall push
    private let forwardProbeFactor: CGFloat = 1.6   // "don't ram" look-ahead in tank-sizes
    private let stuckDuration: TimeInterval = 0.6   // blocked this long ⇒ escape maneuver
    private let escapeDuration: TimeInterval = 0.6  // how long to back-up-and-turn when wedged
    private let cullMargin: CGFloat = 256           // AI stays active this far beyond the view
    // Smoothing time constants — these turn the discontinuous steering signals
    // (binary whisker hits, neighbours moving, blocked/clear flips) into eased
    // motion instead of visible twitching.
    private let headingSmoothingTau: TimeInterval = 0.15 // low-pass on the desired heading
    private let speedSmoothingTau: TimeInterval = 0.2    // ramp toward the target speed
    private let brakeTau: TimeInterval = 0.08            // ramp down when blocked ahead

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

        // NPCs well outside the camera view are skipped entirely: no perception,
        // no navigation, no firing. They idle until the player comes near.
        let activeRegion = activeRegion(context: context)
        let npcs = context.sprites.filter { $0.hasComponent(of: NpcMarker.self) }

        for npc in npcs {
            guard let brain = brain(for: npc) else {
                continue
            }
            if let activeRegion, !activeRegion.contains(npc.position) {
                resetControllerState(for: npc)
                npc.getComponent(of: VelocityComponent.self)?.value = 0
                brain.sinceDecision = 0
                continue
            }

            brain.sinceDecision += deltaTime
            let canSeeTarget = target.map { canSee($0, from: npc, context: context) } ?? false

            // Engaging NPCs decide every frame (crisp aim); the rest re-decide on a
            // throttled, staggered cadence and hold their command in between. That
            // stops two NPCs from mutually re-reacting each frame (the livelock) and
            // smooths motion. Passing the real elapsed time keeps timers correct.
            guard canSeeTarget || brain.sinceDecision >= decisionInterval else {
                continue
            }
            let elapsed = brain.sinceDecision
            brain.sinceDecision = 0

            resetControllerState(for: npc)
            think(
                npc: npc,
                brain: brain,
                target: target,
                nav: nav,
                squad: squad,
                neighbors: npcs,
                canSeeTarget: canSeeTarget,
                deltaTime: elapsed,
                context: context
            )
        }
    }

    /// The camera's visible rectangle expanded by a margin. NPCs outside it are
    /// culled from AI processing. Returns `nil` (no culling) if there's no camera.
    private func activeRegion(context: GameSceneContext) -> CGRect? {
        guard let camera = context.camera else {
            return nil
        }
        let scale = camera.xScale
        let width = context.size.width * scale
        let height = context.size.height * scale
        let rect = CGRect(
            x: camera.position.x - width * 0.5,
            y: camera.position.y - height * 0.5,
            width: width,
            height: height
        )
        return rect.insetBy(dx: -cullMargin, dy: -cullMargin)
    }

    // MARK: - Brain lifecycle

    private func brain(for npc: Sprite) -> AiComponent? {
        if let existing = npc.getComponent(of: AiComponent.self) {
            return existing
        }
        let brain = AiComponent()
        brain.flankSlot = nextFlankSlot
        brain.repathTimer = TimeInterval(nextFlankSlot % 8) * 0.05 // desync repaths
        // Stagger the first decision across NPCs so they never all decide on the
        // same frame — this is what decorrelates their mutual reactions.
        brain.sinceDecision = decisionInterval * TimeInterval(nextFlankSlot % 6) / 6.0
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
        controller.value.turnThrottle = nil
    }

    // MARK: - Decision

    private func think(
        npc: Sprite,
        brain: AiComponent,
        target: Sprite?,
        nav: NavGrid?,
        squad: SquadComponent?,
        neighbors: [Sprite],
        canSeeTarget: Bool,
        deltaTime: TimeInterval,
        context: GameSceneContext
    ) {
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
        case .attack: attack(npc: npc, brain: brain, target: target, neighbors: neighbors, deltaTime: deltaTime, context: context)
        case .chase:  chase(npc: npc, brain: brain, nav: nav, neighbors: neighbors, deltaTime: deltaTime, context: context)
        case .search: search(npc: npc)
        case .patrol: patrol(npc: npc, brain: brain, nav: nav, neighbors: neighbors, deltaTime: deltaTime, context: context)
        }
    }

    // MARK: - States

    private func attack(
        npc: Sprite,
        brain: AiComponent,
        target: Sprite?,
        neighbors: [Sprite],
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
            // Close the distance, steering around walls and away from allies.
            steer(npc: npc, brain: brain, toward: target.position, speedFactor: chaseSpeedFactor, neighbors: neighbors, deltaTime: deltaTime, context: context)
        } else {
            // In range: hold position and aim precisely at the target.
            velocity.value *= 0.9
            aim(npc: npc, at: target.position, controller: controller, deltaTime: deltaTime)
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
        neighbors: [Sprite],
        deltaTime: TimeInterval,
        context: GameSceneContext
    ) {
        guard let goal = brain.lastKnownTargetPosition else {
            return
        }
        // While still far, spread onto a flank so the squad approaches from several
        // sides instead of stacking single-file into each other's line of fire.
        let approach = flankedGoal(goal, npc: npc, brain: brain, nav: nav)
        navigate(npc: npc, brain: brain, to: approach, nav: nav, speedFactor: chaseSpeedFactor, neighbors: neighbors, deltaTime: deltaTime, context: context)
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
        neighbors: [Sprite],
        deltaTime: TimeInterval,
        context: GameSceneContext
    ) {
        guard let nav else {
            // No navigation grid: creep forward and let steering handle avoidance.
            steer(npc: npc, brain: brain, toward: pointAhead(from: npc, distance: 200), speedFactor: patrolSpeedFactor, neighbors: neighbors, deltaTime: deltaTime, context: context)
            return
        }
        if brain.wanderGoal == nil || reached(brain.wanderGoal!, by: npc) {
            brain.wanderGoal = randomWalkablePoint(near: npc.position, nav: nav)
            brain.repathTimer = 0 // force a path to the new goal on the next navigate
        }
        guard let wander = brain.wanderGoal else {
            return
        }
        navigate(npc: npc, brain: brain, to: wander, nav: nav, speedFactor: patrolSpeedFactor, neighbors: neighbors, deltaTime: deltaTime, context: context)
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
        neighbors: [Sprite],
        deltaTime: TimeInterval,
        context: GameSceneContext
    ) {
        guard let nav else {
            steer(npc: npc, brain: brain, toward: goal, speedFactor: speedFactor, neighbors: neighbors, deltaTime: deltaTime, context: context)
            return
        }
        // Pathfinding is strictly time-throttled: recompute at most once per
        // `repathInterval`. Between recomputes we follow the cached waypoints (and
        // steer straight at the goal once they run out), which keeps A* off the
        // per-frame hot path even while chasing a moving target.
        brain.repathTimer -= deltaTime
        if brain.repathTimer <= 0 {
            brain.path = nav.findPath(from: npc.position, to: goal)
            brain.pathIndex = 0
            brain.repathTimer = repathInterval
        }
        let reachSq = (0.6 * Swift.min(nav.tileSize.width, nav.tileSize.height)).sqr()
        while brain.pathIndex < brain.path.count,
              npc.position.squaredDistance(to: brain.path[brain.pathIndex]) < reachSq {
            brain.pathIndex += 1
        }
        let waypoint = brain.pathIndex < brain.path.count ? brain.path[brain.pathIndex] : goal
        steer(npc: npc, brain: brain, toward: waypoint, speedFactor: speedFactor, neighbors: neighbors, deltaTime: deltaTime, context: context)
    }

    /// Blends goal-seeking with separation from nearby NPCs and a soft wall push into
    /// one desired heading (low-pass filtered so the binary steering inputs can't
    /// snap it), turns toward it with a proportional command that eases onto the
    /// heading, and — the key robustness rule — NEVER drives forward into a wall or
    /// another tank. When forward is blocked it brakes and rotates to find an
    /// opening; if it stays wedged, it triggers a short back-up-and-turn escape so
    /// it can't get permanently stuck.
    private func steer(
        npc: Sprite,
        brain: AiComponent,
        toward goal: CGPoint,
        speedFactor: CGFloat,
        neighbors: [Sprite],
        deltaTime: TimeInterval,
        context: GameSceneContext
    ) {
        guard let controller = npc.getComponent(of: ControllerComponent.self),
              let velocity = npc.getComponent(of: VelocityComponent.self) else {
            return
        }

        // Wedge escape takes priority: reverse while turning a slot-determined way
        // (neighbouring tanks pick opposite directions and separate).
        if brain.escapeTimer > 0 {
            brain.escapeTimer -= deltaTime
            velocity.value = -0.3 * velocity.limit // back straight out of the wedge
            if brain.flankSlot % 2 == 0 {
                controller.value.isTurnLeftPressed = true
            } else {
                controller.value.isTurnRightPressed = true
            }
            return
        }

        var direction = normalized(goal - npc.position)
        direction = direction + separationVector(for: npc, neighbors: neighbors) * separationWeight
        direction = direction + wallAvoidanceVector(for: npc, context: context) * wallAvoidWeight
        // If the forces cancel out, keep the current facing rather than snapping.
        var desiredAngle = direction.squaredDistance() > 1e-4 ? direction.atan2() : npc.zRotation
        // Low-pass the heading: whisker hits toggling and neighbours moving make the
        // raw steering direction jump from one decision to the next; blending it
        // over ~headingSmoothingTau turns those jumps into curves.
        if let previous = brain.desiredHeading {
            let alpha = CGFloat(1.0 - exp(-deltaTime / headingSmoothingTau))
            desiredAngle = previous - previous.signedAngleDifference(desiredAngle) * alpha
        }
        brain.desiredHeading = desiredAngle

        let diff = npc.zRotation.signedAngleDifference(desiredAngle)
        controller.value.turnThrottle = turnThrottle(for: npc, diff: diff, horizon: deltaTime)

        // Hard rule: don't keep driving into what's directly ahead. Brake fast (but
        // smoothly), track how long we're blocked, and escape if it persists.
        if isBlockedAhead(npc: npc, context: context) {
            velocity.value *= CGFloat(exp(-deltaTime / brakeTau))
            brain.stuckTimer += deltaTime
            if brain.stuckTimer > stuckDuration {
                brain.escapeTimer = escapeDuration
                brain.stuckTimer = 0
                brain.desiredHeading = nil // re-evaluate fresh after backing out
            }
        } else {
            brain.stuckTimer = 0
            let alignment = Swift.max(0, cos(diff))
            let targetSpeed = speedFactor * velocity.limit * (minMoveSpeedFactor + (1 - minMoveSpeedFactor) * alignment)
            let blend = CGFloat(1.0 - exp(-deltaTime / speedSmoothingTau))
            velocity.value += (targetSpeed - velocity.value) * blend
        }
    }

    /// Proportional turn command in -1...1: saturated (full rate) while far from
    /// the desired heading, easing out near it so the rotation lands exactly on
    /// target instead of bang-bang oscillating around a deadband. `horizon` is how
    /// long the command will be held (the time until the next decision).
    private func turnThrottle(for npc: Sprite, diff: CGFloat, horizon: TimeInterval) -> CGFloat {
        let maxStep = rotationStep(for: npc, deltaTime: Swift.max(horizon, 1.0 / 240.0))
        guard maxStep > 1e-6 else {
            return 0
        }
        // Positive diff = facing counterclockwise of the target ⇒ turn clockwise.
        return (-diff / maxStep).max(-1).min(1)
    }

    /// True if a wall or another tank sits within the forward look-ahead. Projectiles
    /// are ignored. This is the gate that stops NPCs ramming walls and each other.
    private func isBlockedAhead(npc: Sprite, context: GameSceneContext) -> Bool {
        let reach = forwardProbeFactor * npc.size.width.max(npc.size.height)
        let end = pointAhead(from: npc, distance: reach)
        guard let hit = context.nearestHit(from: npc.position, to: end, excluding: npc) else {
            return false
        }
        return isWall(hit) || isTank(hit)
    }

    private func aim(npc: Sprite, at point: CGPoint, controller: ControllerComponent, deltaTime: TimeInterval) {
        // Proportional control converges exactly onto the target angle — no
        // deadband, so no pop-pause-pop stepping while tracking a moving player.
        let diff = npc.zRotation.signedAngleDifference((point - npc.position).atan2())
        controller.value.turnThrottle = turnThrottle(for: npc, diff: diff, horizon: deltaTime)
    }

    /// Sum of repulsion from NPCs inside the separation radius — stronger the closer
    /// they are. This is the anti-crowding / anti-collision force.
    private func separationVector(for npc: Sprite, neighbors: [Sprite]) -> CGPoint {
        let radius = separationRadiusFactor * npc.size.width.max(npc.size.height)
        let radiusSq = radius.sqr()
        var push = CGPoint.zero
        for other in neighbors where other !== npc {
            let away = npc.position - other.position
            let distSq = away.squaredDistance()
            guard distSq < radiusSq, distSq > 1.0 else {
                continue
            }
            let dist = distSq.sqrt()
            // Unit away-vector scaled by how deep inside the radius the neighbour is.
            push = push + away * ((radius - dist) / (radius * dist))
        }
        return push
    }

    /// Soft push away from walls detected by three forward whiskers. Blended with the
    /// goal direction, it curves the NPC around obstacles instead of snapping heading.
    private func wallAvoidanceVector(for npc: Sprite, context: GameSceneContext) -> CGPoint {
        let facing = npc.zRotation
        let probe = avoidanceProbeFactor * npc.size.width.max(npc.size.height)
        var push = CGPoint.zero
        for (offset, weight) in [(CGFloat(0), CGFloat(1.6)), (avoidanceSpread, 1.0), (-avoidanceSpread, 1.0)] {
            let angle = facing + offset
            let end = npc.position + CGPoint.rotated(radians: angle) * probe
            guard let hit = context.nearestHit(from: npc.position, to: end, excluding: npc), isWall(hit) else {
                continue
            }
            push = push - CGPoint.rotated(radians: angle) * weight
        }
        return push
    }

    private func rotationStep(for npc: Sprite, deltaTime: TimeInterval) -> CGFloat {
        (npc.getComponent(of: RotationSpeedComponent.self)?.value ?? defaultRotationSpeed) * deltaTime
    }

    private func normalized(_ vector: CGPoint) -> CGPoint {
        let lengthSq = vector.squaredDistance()
        guard lengthSq > 1e-6 else {
            return .zero
        }
        return vector * (1.0 / lengthSq.sqrt())
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

    private func isTank(_ sprite: Sprite) -> Bool {
        sprite.hasComponent(of: NpcMarker.self) || sprite.hasComponent(of: PlayerMarker.self)
    }
}
