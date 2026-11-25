# Street Legend — First Download Quality Gate

This gate is intentionally stricter than a scene that merely opens. The first Android release candidate must be evaluated on a real device and not presented as finished until these items are checked.

## Feel and presentation
- [ ] Boot into a branded splash/title flow with a clear Play / Continue action.
- [ ] Avoid empty or placeholder UI during scene loading; provide a loading state.
- [ ] Camera keeps the fighter framed, eases rather than snaps, and collision prevents clipping.
- [ ] Player movement, attacks, guard and recovery respond consistently to touch.
- [ ] Animation transitions avoid abrupt pose snaps; attack anticipation and hit reactions align with hit validation.
- [ ] Soundscape includes combat, movement, impact, environment and restrained commentator lines; subtitles are toggleable.

## Combat integrity
- [ ] Hits only resolve within range, facing arc and unobstructed path.
- [ ] Both fighters can be interrupted during wind-up.
- [ ] Knockout disables combat but does not freeze gravity or produce clipping.
- [ ] Enemy approach, lateral movement and retreat do not lead to wall trapping or endless orbiting.
- [ ] Attack feedback is triggered only on confirmed hits, not misses.

## Environment and navigation
- [ ] Walls, floors, doorways and stairs use verified collision surfaces.
- [ ] Spawn points are on the floor and clear of walls.
- [ ] Fall recovery and respawn are tested for edge cases.
- [ ] Props cannot block essential navigation or trap either fighter.

## Android performance / stability
- [ ] Build is tested on a real Android device, including a lower-end target.
- [ ] Target stable frame pacing with a conservative frame-rate target and quality scaling.
- [ ] Profile memory, CPU/GPU frame time, thermal behavior and battery drain.
- [ ] Pool repeated effects where useful; avoid gameplay-time allocations and spikes.
- [ ] Verify touch layout on narrow and tall screen ratios, including safe areas.
- [ ] Confirm pause, resume, restart, app backgrounding and audio focus.
- [ ] No Unity compilation errors, missing assets, fatal log errors or crashes.

## Campaign first impression
- [ ] Hotel opening is visually coherent and navigable.
- [ ] Mission goals and next actions are clear.
- [ ] The rescue story beat is staged sensitively and remains non-graphic.
- [ ] Victory / retry flow works and does not require restarting the app.

Structural CI checks are not a substitute for Unity Editor, Play Mode or device tests. This gate tracks those pending checks explicitly.
