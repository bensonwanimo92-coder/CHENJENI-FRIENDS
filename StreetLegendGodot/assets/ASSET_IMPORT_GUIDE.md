# Street Legend asset slots and verification

Use compact, licensed GLB 2.0 files with embedded textures where possible.

## Fighter slots
- `assets/fighters/player.glb`: hero, approximately 1.8 m, feet at origin, faces -Z.
- `assets/fighters/enemy.glb`: standard opponent, matching scale/orientation.
- `assets/fighters/boss.glb`: boss, matching scale/orientation.

Rigged models should include skeleton and skin. Suggested animation clips: idle, walk/run, punch, kick, block, dodge, hit, knockdown and get-up. The current combat loader uses these exact slots; it may fall back to procedural visuals.

## Environment slots
- `assets/environment/road.glb`
- `assets/environment/buildings.glb`
- `assets/environment/bridge.glb`
- `assets/vehicles/vehicle.glb`

## Asset acceptance checks
1. Keep each asset's source, license and attribution in the asset ledger.
2. Put GLB files in the exact slots above. Preserve sidecar textures or dependencies if not embedded.
3. Open the project in Godot 4.3 and wait for import completion.
4. Inspect scale, orientation, materials and mesh visibility in the editor.
5. Test in an actual campaign scene and on the target Android device; presence of a file alone is not evidence of correct rendering or performance.

## Automated slot audit
From the project root, run:
`godot --headless --script scripts/asset_audit.gd`
The script reports file presence only. It does not validate licensing, successful import, rig, animation, appearance or performance.

Do not commit ripped or unlicensed assets. Procedural fallback geometry is not considered a real asset import.
