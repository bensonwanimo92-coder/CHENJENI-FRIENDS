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

The first scene is a greybox: primitive capsules, lobby walls and placeholder geometry. It is for proving the initial scene and combat loop, not final art.

## Important limitations
- This scaffold has not yet been opened or compiled in Unity in this environment.
- Player and opponent attacks now check range, facing arc and raycast line of sight; enemy hits reduce player prototype health. These checks are preliminary and still require Unity testing.
- Keyboard input is currently wired; Android touch controls, animation rigs, audio, proper hitboxes, UI, full campaign scenes and production character/environment assets remain to be implemented.
- A fall-recovery safety component is included in the generated hotel scene; it returns a fighter below the configured kill plane to its starting position. Checkpoints and recovery tuning still need level-specific setup and testing.\n- The follow camera now uses a sphere cast to reduce clipping through walls; camera behavior still needs testing in tight corridors and around corners.\n- Physics/geometry acceptance tests are documented in `PHYSICS_GEOMETRY_AND_COLLISION_CHECKLIST.md`.\n- The voice-only gameplay commentator design is documented in `COMMENTATOR_SYSTEM.md`; actual event hooks, voice recordings and subtitle integration are not implemented yet.
- No APK has been built or device-tested.
- The project uses original placeholder geometry and does not include proprietary Leonida/GTA assets.

## Next milestone
Open the project in Unity, resolve any editor-version/import issues, generate the hotel scene, then compile and test the camera, fall recovery and combat checks. Next wire mobile controls, animation-timed martial-arts hitboxes and the voice-only commentator before making an Android build.
