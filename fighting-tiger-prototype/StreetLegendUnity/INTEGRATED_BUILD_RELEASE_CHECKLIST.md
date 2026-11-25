# Street Legend Integrated Build / Commit Audit

This checklist is the release-control record for integrating source changes into one Unity game. A commit is not considered game-integrated merely because it exists on GitHub.

## Integration rules
- Work from the project's agreed default branch and Unity version (Unity 6000.0.32f1).
- Keep a record of commits/files changed for each feature and resolve dependencies before scene integration.
- Generated scenes must reference the intended controllers, HUDs, cameras, animation assets, audio and event systems.
- Avoid silently dropping or reverting previously accepted features when updating scenes or scripts.
- Do not ship a partial APK while integration and QA gates remain outstanding.

## Level 1 integration inventory
- [ ] Landscape Android orientation and touch HUD.
- [ ] Hotel scene, fighter prefabs and fallback actors.
- [ ] Player movement, gravity, recovery, attacks and hit validation.
- [ ] Enemy AI movement, defense, attack impact validation and defeat.
- [ ] Health display, match flow, pause/retry and outcome UI.
- [ ] Voice-only commentator and subtitles/preferences.
- [ ] Hotel encounter transitions into pursuit without stale victory overlay/time-scale.
- [ ] Vehicle controller, driving HUD, camera and route target.
- [ ] Pursuit does not catch target; roadblock trigger stops vehicle.
- [ ] Staged vehicle-to-player transition and visibility/camera/HUD handoff.
- [ ] Separate roadblock enemy, target linkage, combat, win/defeat and retry.
- [ ] Main menu, scene loading, build scene settings and Android configuration.

## Unity verification (must be performed in Unity; source checks alone cannot pass these)
- [ ] Project opens with target Unity version; imports complete with no errors.
- [ ] Run structural gate and review every warning/error.
- [ ] Run generated hotel and pursuit scenes in Play Mode.
- [ ] Test movement, attacks, hit/LOS, AI, falls/recovery and boundaries.
- [ ] Test transition sequence, drive controls, camera, roadblock collision and dismount staging.
- [ ] Test roadblock combat, both outcomes, retry, pause and resume.
- [ ] Confirm mobile UI layout, touch responsiveness, audio and performance.
- [ ] Inspect console; resolve compilation errors and relevant warnings.
- [ ] Build Android APK only after gates pass; install and test on an authorized physical device.
- [ ] Record APK version/build, tested device, test results and release commit.

## Honesty/status
A checklist or source-level validator does not prove C# compilation, Play Mode success, Android build success, installation or device QA. Mark those items only after actually performing them.
