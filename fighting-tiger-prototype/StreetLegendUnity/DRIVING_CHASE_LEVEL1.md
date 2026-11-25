# Street Legend — Level 1 Driving Chase / Roadblock transition

## Canonical sequence

1. **Hotel escape** — opening combat ends when the mission objective is cleared. A cinematic beat shows the abductors' Range Rover pulling away.
2. **Vehicle entry** — Wanimo runs to his parked car, opens/enters the driver seat (transition animation when assets are ready), and control transfers to driving. Camera moves to a third-person chase camera. Landscape HUD swaps from fighting controls to driving controls.
3. **Pursuit** — Wanimo follows the Range Rover through an original Leonida street route. The target vehicle stays ahead and is scripted not to be caught: mission pacing is distance-band based, not a race-to-catch. The player still drives, steers, brakes, accelerates, and can take believable turns; target lead is maintained through route pacing and staged sightline breaks rather than teleporting the player.
4. **Roadblock foreshadowing** — signs, sirens, traffic, debris, distant NPC signals and roadblock vehicles foreshadow the obstruction. Audio and camera cues should warn, not unfairly surprise the player.
5. **Roadblock stop** — a controlled roadblock narrows or closes the route. Wanimo brakes and stops before the barrier. The Range Rover escapes around/through the route bend and remains visible briefly, then exits scene. No collision should launch or clip the player car through geometry.
6. **Vehicle exit** — a short exit animation/transition, driving input is disabled, the player character is placed on stable ground beside the car, and the fight camera/HUD fades in. No overlap between vehicle control and combat input.
7. **Roadblock combat** — first Level 1 combat encounter begins against roadblock guards. Fight objective and HUD are displayed; the car and barrier remain nonpenetrable obstacles. Enemies spawn on safe ground, not inside the player or walls.
8. **Level 1 ending** — clear the encounter, checkpoint, brief narrative reveal and campaign handoff. This ends the Level 1 driving/combat sequence without letting Wanimo catch the Range Rover.

## Driving design

- Third-person chase camera with obstruction-aware camera collision; avoid camera snapping through buildings.
- Mobile steering: left/right steer, accelerator and brake controls; handbrake optional only after basic handling is reliable. Separate driving HUD from fighting HUD and restore fighting controls only on exit.
- Basic vehicle physics: wheel/contact suspension, traction, braking, steering response, speed limit, drag, body roll kept readable, collisions and recovery/reset for stuck/overturned car. Do not simulate excessively complex tire physics until stable and performant on Android.
- Use a simple route/waypoint spline for the target SUV. Keep it consistently ahead using pacing and route timing. Maintain a minimum and maximum distance band; if player is too close, target safely advances; if player is far, target slows within plausible limits or mission uses staged route/sightline breaks.
- Avoid abrupt AI target steering, cars clipping through walls, roadblock spawning in front of the player at unsafe distance, or automatic acceleration overriding player's steering/braking.
- Roadblock is a mission transition trigger, not an arbitrary hard stop: road geometry, barriers, cones and vehicles should physically explain the stop. Stop player's car at a safe point, then transition to combat on a validated ground point.

## Systems / scene boundaries

- Hotel Escape combat phase -> Pursuit Driving phase -> Roadblock -> Roadblock Combat phase.
- Driving controls and camera are distinct from fighter controls/camera; phases own input, camera, HUD and audio state. One phase at a time; transition restores time scale and controls on cancellation/restart.
- Vehicle target, roadblock trigger and combat trigger must use explicit mission-state checks to prevent double activation. Player can retry from pursuit checkpoint.
- Vehicle and world geometry need validation: wheel-ground contact, collider bounds, door/exit position, roadblock collision, safe player placement, target path clearance, and camera occlusion.

## Acceptance gates (not yet runtime verified)

- Player can accelerate, brake, steer and stop without input conflicts.
- Range Rover remains ahead throughout pursuit; no catch-up collision or abrupt teleporting.
- Roadblock is visible and legible; player has enough distance to brake.
- Vehicle does not clip through barrier/buildings or flip from modest contact.
- Exit placement puts player on stable ground outside the car and barrier.
- Combat begins once, with enemies at valid positions; combat HUD/camera/input replaces driving HUD/camera/input.
- Restart/checkpoint resets both vehicles and phase state correctly.
- Performance, touch layout and camera are checked on actual Android device only after user authorizes device testing.

This is a committed mission design/engineering specification, not an implemented or tested driving system. Driving controller, vehicle assets, scene generation, target AI, and phase transitions remain to be built and validated.
