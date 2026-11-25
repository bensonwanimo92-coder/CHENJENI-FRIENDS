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
- Physics/geometry acceptance tests are documented in `PHYSICS_GEOMETRY_AND_COLLISION_CHECKLIST.md`.
- No APK has been built or device-tested.
- The project uses original placeholder geometry and does not include proprietary Leonida/GTA assets.

## Next milestone
Open the project in Unity, resolve any editor-version/import issues, generate the hotel scene, then wire health, opponent attacks, mobile controls and animation-timed martial-arts hitboxes before making an Android build.
