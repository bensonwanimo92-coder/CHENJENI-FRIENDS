# Street Legend imported asset slots

Use original or clearly licensed GLB 2.0 files (Godot-friendly) and include textures embedded where possible.

## Fighter scenes
- `fighters/player.glb`: playable hero, feet at origin, forward direction -Z, roughly 1.8m tall.
- `fighters/enemy.glb`: standard enemies, same scale/origin.
- `fighters/boss.glb`: boss character, same scale/origin.
Character scenes should include a skeleton, skin, and animations; animation clips recommended: idle, walk/run, punch, kick, block, dodge, hit, knockdown, get-up.

## Environment
- `environment/road.glb`: roadway and road markings.
- `environment/buildings.glb`: modular urban buildings/streetscape.
- `environment/bridge.glb`: bridge geometry and railings.
- `vehicles/vehicle.glb`: vehicle mesh and materials. Driving physics/control integration is a separate task.

The combat script detects these exact paths and instantiates them when present. Procedural geometry remains a fallback until actual imported files are present.

Do not add copyrighted or ripped game assets. Keep the source, license, attribution, and asset version recorded here before committing binary assets. Prefer compact GLB with embedded textures for Android.
