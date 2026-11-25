# Street Legend — Godot migration

## Decision
Godot 4 is the new target engine for the Android game. The Unity project is retained unchanged as a reference and asset source; no Unity files are deleted or overwritten.

## Existing design and gameplay scope to preserve
- Landscape, third-person mobile action/fighting presentation.
- Wanimo as the player character; enemy fighters with readable reactions, knockdowns and recovery.
- Level 1 flow: hotel encounter → Wanimo enters his car → follows (but never catches) the Range Rover → roadblock stops the chase → roadblock fight.
- The chase ends at the roadblock; it must not accidentally skip the first level's final fight.
- A later child-rescue sequence: the child reacts and calls for help when carried/rescued; the child is a protected non-combatant and is never targeted.
- Voice-only commentator describing player actions, hits, knockdowns, mission transitions and results; subtitles may be offered as an accessibility option.
- Touch controls for Android, camera framing and performance tuned for landscape phones.

## Unity source systems audited
The original Unity source scripts in `fighting-tiger-prototype/StreetLegendUnity/Assets/Scripts/` were inspected, including:
- `PrototypeFighterController.cs`: movement, gravity, hit-stun, light/heavy attack cooldowns, attack wind-up, range/angle/obstruction validation, mobile movement input, damage and KO events.
- `PrototypeOpponent.cs`: tactical approach/circle/retreat, attack wind-up and impact revalidation, guard chance/cooldown, damage and KO.
- `PrototypeCameraFollow.cs`: smoothed follow and collision-aware camera placement.
- `StreetLegendVehicleController.cs`, `StreetLegendChaseTarget.cs`, `StreetLegendDrivingHUD.cs`: arcade vehicle handling, ahead-of-player pursuit vehicle, steering and hold controls.
- `StreetLegendMissionPhase.cs` and `StreetLegendMissionIntegrationDirector.cs`: hotel victory handoff, driving pursuit, roadblock, dismount, roadblock combat and retry/result flow.
- `PrototypeCommentatorManager.cs` and `StreetLegendGameplayEvents.cs`: event-based, voice-only commentary, cooldown/priority queue and optional subtitles.
- `PrototypeMatchManager.cs` and `PrototypeMobileHUD.cs`: round lifecycle and mobile HUD source.

## Godot implementation committed
- Godot 4 project configuration: landscape 1280×720 viewport and GL Compatibility/mobile renderer.
- Procedural greybox combat arena, player and enemy capsule placeholders.
- Player controller now includes light/heavy attacks, wind-up delay, range and facing-angle checks, line-of-sight check, hit-stun, knockback, health and knockout signals.
- Enemy AI includes pursuit, circling/retreat decisions, attack timing, guard chance/cooldown, damage and knockout signals.
- Vehicle controller ports arcade acceleration, braking, steering, lateral grip and speed limiting.
- Chase target follows authored waypoints and is deliberately configured to remain ahead rather than be caught.
- Third-person camera follow script.
- Mission flow state machine defines hotel combat, pursuit, roadblock, dismount, roadblock combat and completion/retry outcomes.
- Voice-only commentator event queue with optional subtitle presentation; original Unity Android TTS bridge is not yet ported and no voice recordings are bundled.
- Landscape touch input overlay supports a movement joystick, light/heavy strikes, and driving steer/gas/brake input.
- Main greybox scene now attaches the touch combat controls.
- GitHub Actions workflow added at `.github/workflows/godot-check.yml` to run a headless import/parse and startup smoke check.

## What is not yet complete
- The mission-flow, vehicle and chase scripts exist, but are not yet fully wired into the main scene as a playable end-to-end hotel-to-roadblock sequence.
- Final realistic fighter, child, vehicle, Range Rover, hotel, city and roadblock assets are not yet imported.
- Unity Animator state machines and animation clips have not been converted into Godot AnimationTree/AnimationPlayer resources.
- The child-rescue mission and child help-call reactions are not implemented in Godot yet.
- Voice-only commentary currently queues subtitle text/timing; Android TextToSpeech/audio clip playback still needs a platform implementation.
- No Godot executable is installed in the current editing environment, so no local parser, runtime, desktop build or Android export has been run. The new CI workflow must run successfully before the project can be described as validated.
- No APK has been built.

## Migration map
| Unity source | Godot target |
|---|---|
| PrototypeFighterController | `scripts/fighter.gd` |
| PrototypeOpponent | `scripts/enemy_ai.gd` |
| PrototypeCameraFollow | `scripts/third_person_camera.gd` |
| PrototypeMobileHUD / StreetLegendDrivingHUD | `scripts/mobile_controls.gd` |
| StreetLegendVehicleController | `scripts/vehicle_controller.gd` |
| StreetLegendChaseTarget | `scripts/chase_target.gd` |
| StreetLegendMissionPhase / IntegrationDirector | `scripts/mission_flow.gd` |
| PrototypeCommentatorManager / GameplayEvents | `scripts/commentator.gd`, `scripts/gameplay_events.gd` |
| Unity editor scene builders | native `.tscn` scenes and reusable scene scripts |

## Quality gates before first APK
1. Pass the new Godot headless CI import/parser and startup smoke checks.
2. Wire and test the complete hotel-to-driving-to-roadblock mission flow.
3. Verify combat movement, targeting, hit validation, guard, knockback, KO and retry flow.
4. Verify landscape touch controls on a real device when authorized; no unapproved emulator testing.
5. Integrate original or properly licensed fighter/vehicle/environment assets and animation sets.
6. Configure Godot Android export templates, Android SDK/JDK in CI, then export a debug APK.
7. Test the APK on an authorized physical Android device, then run release checks.

## Asset preservation
Copy/import only original or properly licensed source assets from the Unity project. Keep a source inventory and record any asset that cannot be converted directly. Never assume Unity `.asset`, `.prefab`, `.unity`, or `.meta` files are directly usable by Godot.
