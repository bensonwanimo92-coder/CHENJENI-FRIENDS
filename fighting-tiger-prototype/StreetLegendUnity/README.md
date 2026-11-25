# Street Legend — Unity Starter Project

This is the first Unity project scaffold for the Street Legend hotel-combat prototype.

## Open in Unity
1. Install Unity Hub and a Unity 6 editor (the project marker currently targets 6000.0.32f1).
2. In Unity Hub choose **Add > Add project from disk** and select this `StreetLegendUnity` folder.
3. Let Unity import and compile the scripts.
4. In the Unity menu choose **Street Legend > Build Hotel Prototype Scene**.
5. Open `Assets/Scenes/Level1_Hotel_Prototype.unity` and press Play.

## Prototype controls
- WASD / arrow keys: move.
- J: light attack.
- K: heavy attack.
- Android: lower-left touch joystick to move; tap the blue LIGHT area for a light strike; tap the red HEAVY area for a heavy strike. The touch HUD shows both fighters’ health.
- P: pause/resume.
- R: restart after a win or defeat. On Android, tap after the round ends to restart; tap while paused to resume.

The hotel environment is still greybox geometry. The scene generator now loads the generated Wanimoo and Hotel Enforcer prefabs when they exist; until those FBX files have been generated, imported and prepared, it safely falls back to capsule placeholders.

## Important limitations
- This scaffold has not yet been opened or compiled in Unity in this environment.
- Player and opponent attacks now have a short anticipation/wind-up before impact, then re-check range, facing arc and raycast line of sight at the actual impact moment. A target that moves away or is shielded by level geometry can avoid the hit. These are timed gameplay windows, not yet synchronized to authored punch/kick animation clips; Unity testing is still required.
- Keyboard input is currently wired; Android touch movement and light/heavy attack input plus live player/opponent health bars are generated at runtime in the hotel scene. A match manager now handles victory, defeat, pause and restart; the enemy uses a basic sphere-cast steering probe to try to move around nearby obstructions rather than blindly walking straight into them. The HUD is a first-pass touch layout; device safe-area, multi-resolution and real-device responsiveness still need testing. Animation rigs, audio, proper animation-driven hitboxes, full campaign scenes and production character/environment assets remain to be implemented.
- A fall-recovery safety component is included in the generated hotel scene; it returns a fighter below the configured kill plane to its starting position. Checkpoints and recovery tuning still need level-specific setup and testing.
- The follow camera now uses a sphere cast to reduce clipping through walls; camera behavior still needs testing in tight corridors and around corners.
- Physics/geometry acceptance tests are documented in `PHYSICS_GEOMETRY_AND_COLLISION_CHECKLIST.md`.
- Typed gameplay events now report player movement transitions, combat-range entry/exit, attack starts/misses, confirmed hits, player damage/knockout, opponent attacks/damage and opponent defeat. These events are the foundation for commentary and other game systems.
- A voice-only `PrototypeCommentatorManager` is attached by the hotel scene generator. It supports assigned voice-clip variations and, when clips are absent on Android, built-in Android TextToSpeech commentary with default lines for movement, combat range, attacks, misses, confirmed hits, damage and round outcomes. Optional subtitles can be enabled through its public settings method. The Android system voice and language availability vary by device; no custom recorded commentator performance is included.
- The commentator has no visible character or portrait. It is an audio-only scene component; optional subtitles are plain text only. Its playback coroutine is reset cleanly when the component is disabled and re-enabled.
- Knocked-out players continue to receive gravity and settle onto the floor; movement input is disabled and a movement-stop event is emitted.
- No APK has been built or device-tested.
- The project uses original placeholder geometry and does not include proprietary Leonida/GTA assets.

## Fighter character asset pipeline

A first procedural, rigged human-base generator is included at `Tools/Blender/generate_fighter_pair.py`.

1. Install Blender 4.x with FBX export enabled.
2. Run the script in Blender (or use `blender --background --python Tools/Blender/generate_fighter_pair.py`).
3. Copy the two exports from the script's `Assets/Characters/Generated` output folder into this Unity project's `Assets/Characters/Generated/` folder:
   - `Wanimoo_Player.fbx`
   - `Hotel_Enforcer.fbx`
4. Let Unity import them. The editor asset pipeline configures Humanoid import settings.
5. In Unity choose **Street Legend > Characters > Prepare Fighter Prefabs** to create root-level CharacterController prefabs in `Assets/Characters/Prefabs/`.

The generator builds two distinct, proportioned, bone-deformable human base meshes with separate body/clothing materials, head details, and a humanoid bone hierarchy. It now also exports starter Idle, Walk, Guard, Jab, HeavyKick, HitReact and Knockout animation takes; the Unity editor pipeline builds an Animator Controller from imported takes when they are present. They are a useful rigged prototype starting point, **not finished photorealistic AAA characters**: detailed sculpting, high-resolution skin/clothing textures, facial rigging, hair, and motion-capture-quality animation polish are still required. The starter Blender poses have not yet been visually checked in Blender or Unity and need tuning against the imported skeleton. Check the imported Avatar mapping and CharacterController fit before using the prefabs in a gameplay scene. Do not claim the assets are integrated until the FBX files have been generated and imported in Unity.

## Next milestone
Open the project in Unity, resolve any editor-version/import issues, generate the hotel scene, then compile and test the camera, fall recovery and combat checks. Next assign original commentator recordings, add more traversal/interaction event coverage, then wire mobile controls and animation-timed martial-arts hitboxes before making an Android build.
