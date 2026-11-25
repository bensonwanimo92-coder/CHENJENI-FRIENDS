# Street Legend Unity setup — minimize manual steps

## Exact editor target
- Unity **6000.0.32f1** is the version recorded by this project.
- Use Unity Hub to install that editor version with **Android Build Support**, **Android SDK & NDK Tools**, and **OpenJDK**. Avoid editor-version upgrades mid-integration unless planned.
- Open the project folder: `fighting-tiger-prototype/StreetLegendUnity`. If Unity Hub requires a project root, this folder is the intended root; its completeness must be checked by the editor before attempting build.

## One-click scene bootstrap
1. Open Unity Editor and wait for initial import/compile to settle.
2. From the menu, choose **Street Legend → Setup Project Scenes (One Click)**.
3. Confirm. The editor tool invokes the hotel scene generator and main-menu generator, then registers the two scenes in build settings and locks orientation to landscape.
4. Run **Street Legend → Validate Hotel Prototype**. This is a structural check, not Play Mode testing.
5. Open the menu scene and press Play; select PLAY CAMPAIGN and test transitions, fight controls, pause/restart, health/KO and commentator. Repeat on a physical phone only when authorized.

## Expected build scene order
1. `Assets/Scenes/StreetLegend_MainMenu.unity`
2. `Assets/Scenes/Level1_Hotel_Prototype.unity`

Android build command in the editor: **Street Legend → Build Android APK**.

## Avoid setup time being wasted
- Don't manually create canvases, fighters, walls or cameras: scene-builder scripts generate the starter scene.
- If a compilation error exists, stop and resolve all errors first; don't attempt APK builds with red Console errors.
- Keep the recorded Unity version unchanged until first successful editor compilation.
- Do not install optional Cinemachine/URP upgrades during this initial compile gate unless a concrete error or task needs them.
- Prioritize the first APK after the minimum integration gate: Unity compilation succeeds, scenes and controls are wired, core Level 1 transitions are checked in Play Mode, and no blocking errors remain. Treat visual polish and non-blocking refinements as post-first-APK upgrades, but do not silently omit them from the backlog.

## Remaining gates
- [ ] Unity opens project and imports without errors.
- [ ] One-click scene setup succeeds.
- [ ] Editor compilation passes.
- [ ] Menu and mission scene wiring passes validation.
- [ ] Play Mode startup/transition passes.
- [ ] Combat/collision/camera/UI/commentary checks pass.
- [ ] Android build succeeds.
- [ ] Phone installation and QA (only with authorization).
