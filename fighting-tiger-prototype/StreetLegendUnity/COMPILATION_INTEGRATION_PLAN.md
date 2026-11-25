# Street Legend: integration and pre-compilation plan

This document defines the next integration pass. Repository checks and source inspection do not constitute Unity compilation, Play Mode QA, Android build, or device testing.

## Integration target
- Keep the hotel combat prototype as the starting scene and the menu as the entry scene.
- Preserve landscape orientation.
- Integrate the hotel fight outcome with a mission state handoff, rather than leaving driving as a disconnected test scene.
- Keep the pursuit and roadblock sequence behind explicit phase transitions.
- Preserve restart/pause controls and prevent Time.timeScale from leaking between scenes.
- Use the driving test scene as a temporary physics/control validation environment until the mission is connected.

## Integration order
1. Open Unity 6000.0.32f1 and allow imports/compiler to finish.
2. Run **Street Legend / Pre-Compilation Structural Gate**. Resolve missing-file errors and warnings.
3. Run **Street Legend / Setup Project Scenes (One Click)** to generate/register menu and hotel scenes.
4. Run **Street Legend / Build Driving Chase Test Scene**.
5. Run **Street Legend / Validate Driving Test Scene** and **Street Legend / Validate Hotel Prototype**.
6. Inspect Play Mode: hotel collision and walls, attacks/hit timing, enemy navigation and KO, menu navigation, restart/pause.
7. Inspect driving Play Mode: steering sensitivity, throttle/braking, Rigidbody stability, target path and roadblock stop.
8. Integrate the hotel victory/escape event into a pursuit launch sequence; add a visible player car-entry cue and camera transition.
9. Integrate roadblock stop into a player exit sequence; test spawn/exit position, camera, HUD switch, combat handoff, and fight restart.
10. Run a clean Android build only after editor checks and mission QA are complete.

## Integration blockers to resolve before APK
- Hotel scene currently has no mission-level car/escape handoff wired to the combat outcome.
- Driving scene remains a generated test scene, separate from the hotel mission.
- The current roadblock transition changes phases and can enable an assigned fighter, but does not yet animate or choreograph exiting the car.
- The chase target uses prototype waypoint behavior; route quality and physical collision must be tested in Play Mode.
- Placeholder geometry and placeholder fighters are not final art.
- Commentator coverage for vehicle pursuit and mission phase events needs to be connected and tested.

## Acceptance checks
- No player/enemy clipping through walls or floors during tested encounters.
- Attacks visibly connect only when impact validation confirms a hit; misses do not damage.
- Knockout, victory/defeat, pause, restart and transitions work without frozen time.
- Vehicle cannot teleport/catch the fleeing target unnaturally; chase route and speed are tuned.
- Roadblock stops vehicle reliably; player exit and combat handoff are controlled.
- Touch controls do not interfere with one another; UI buttons release on touch cancellation.
- Landscape layout and readable HUD are checked on a target Android device only with user authorization.
- No APK is presented as ready before these checks pass.

## Scope of current structural gate
The Editor gate checks expected source files, scene registration, and basic orientation. It cannot detect C# compiler errors, animation errors, runtime exceptions, gameplay defects, or Android build failures.
