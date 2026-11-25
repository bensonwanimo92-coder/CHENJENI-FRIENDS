# Street Legend — Unity 3D Migration

**Engine selected: Unity 6 + Universal Render Pipeline (URP)**

This folder begins the migration from the Canvas proof-of-concept to a real mobile-first 3D fighting game. The browser prototype remains available while the Unity project is developed separately.

## Target
- Android first; touch controls and performance targets for low/mid-range phones.
- 3D humanoid fighters using rigged models and animation clips (no placeholder stick figures in the finished game).
- URP, baked lighting where appropriate, shadow and quality presets, pooled impact effects.
- Third-person arena camera; Cinemachine when installed in the Unity project.
- C# combat systems, enemy AI, missions, character unlocks and progression.

## Setup
1. Install Unity 6 LTS with Android Build Support, SDK/NDK and OpenJDK modules.
2. Create a separate Unity project using the **Universal 3D (URP)** template inside `unity-migration/` (this repository currently holds starter source, not a Unity-generated project).
3. Copy `Assets/Scripts` into the project's `Assets/Scripts` folder.
4. Add a humanoid character with Animator and Rigidbody; configure ground collider and attack/block/dodge input.
5. Configure Animator parameters referenced in the scripts and add real animation clips; connect UI buttons to combat methods.
6. Build for Android and test on-device before releasing.

## Graphics & gameplay pipeline
- Model/rig: humanoid FBX, Unity Humanoid avatar, retargeted combat animations.
- Rendering: URP, physically based materials, arena props, restrained post-processing, scalable quality settings.
- Combat: animation event-driven hit windows, stamina, blocking, dodge, combo and special attacks.
- AI: distance management, telegraphed attacks, stagger and difficulty tiers.

## Status
Migration decision and initial C# systems are committed. This is **not yet a Unity project or APK**; engine editor setup, licensed/created models and animations, scene wiring, playtesting and Android builds remain.


## Character art direction (locked)
- Grounded human proportions: average/athletic physiques, no oversized muscles or superhero silhouettes.
- Natural facial anatomy and realistic skin/material shading; avoid caricature and exaggerated features.
- Streetwear and practical fight clothing (hoodies, tees, jeans, tracksuits, sneakers, wraps, gloves as appropriate).
- Combat animation should convey weight, balance, footwork and believable recovery; prioritize grounded movement over flashy fantasy moves.
- Visual target: approachable, realistic street-fighting game characters, scalable for Android performance.


## Mobile scene and gameplay layout
- Camera: follow target with soft damping; frame both fighters, retain player-side screen orientation, and avoid extreme zoom or shaky camera motion.
- Arena: compact urban training/street arena, collision boundaries, simple props and modular materials.
- Player controls: UI buttons for move/joystick, punch, kick, guard, dodge and special. Provide safe touch margins and configurable layout.
- Performance: scalable render quality, shadow distance/softness options, effect pooling, conservative post-processing, texture compression and target frame rate options.
- Fight flow: menu -> character selection -> stage intro -> combat -> results -> next stage. Pause and restart supported.
- Assets: only use assets with licenses suitable for distribution or assets created for this project. Keep asset credits/licenses documented.
