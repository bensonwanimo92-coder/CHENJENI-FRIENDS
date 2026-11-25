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
## Migration map
| Unity source | Godot target |
|---|---|
| PrototypeFighterController | scripts/fighter.gd plus mobile input layer |
| PrototypeOpponent | scripts/enemy_ai.gd |
| PrototypeCameraFollow | third-person Camera3D rig |
| PrototypeMobileHUD | CanvasLayer HUD and touch controls |
| StreetLegendVehicleController / ChaseTarget | vehicle controller and chase state machine |
| StreetLegendMissionPhase / IntegrationDirector | mission state machine |
| PrototypeCommentatorManager | audio event router and subtitle UI |
| Unity editor scene builders | native .tscn scenes and reusable scene scripts |
## Current implementation
- Godot project scaffold and landscape viewport settings.
- Procedural greybox combat arena with two capsule placeholders.
- Initial player movement, melee range/damage and enemy pursuit/attack logic.
- This is a migration foundation, not final character art, animation, vehicle chase, Android controls, or a tested APK.
## Quality gates before first APK
1. Open/import the project in Godot 4 and resolve parser/runtime errors.
2. Verify combat movement, targeting, damage, KO and restart flow in desktop play.
3. Implement the complete hotel-to-driving-to-roadblock mission flow.
4. Add landscape touch controls and Android performance settings.
5. Integrate licensed fighter/vehicle/environment assets and animations.
6. Export a debug APK, install/test on an authorized physical Android device, then run release checks.
## Asset preservation
Copy/import only original or properly licensed source assets from the Unity project. Keep a source inventory and record any asset that cannot be converted directly. Never assume Unity .asset, .prefab, .unity, or .meta files are directly usable by Godot.
