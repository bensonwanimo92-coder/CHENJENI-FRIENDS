# Street Legend — Genuine Asset Acquisition & Integration Plan

This document is the asset procurement gate for the Godot build. Placeholder geometry is not considered production content.

## Priority asset requirements
1. Main playable character: realistic humanoid, rigged, preferably humanoid-compatible skeleton, neutral pose, skin/clothing materials, source licence recorded.
2. Enforcers: 2-4 distinct realistic humanoid variants with compatible skeletons.
3. Animation set: locomotion, idle, run, turn, light punches, heavy strikes/kicks, block, dodge, stagger, hit, fall, recovery, knockout.
4. Vehicles: player car and escaping SUV, game-ready meshes with wheels, interior/driver visibility where feasible; avoid trademarked branding unless licensed.
5. Hotel: lobby kit (floor, wall, reception, furniture, doors, lights), stairs/corridor modules, signage.
6. Street/roadblock: asphalt, sidewalks, road markings, barriers, vehicles/props, urban facades and lighting.
7. Rescue mission later: child model (non-combatant), safe carry/rescue animation, civilian props.
8. Audio: licensed/original impact, footsteps, ambience, vehicle and voice assets.

## Preferred sources (verify each asset's current licence and download terms before use)
- Mixamo: humanoid characters/animation; record the asset and usage terms; test retargeting.
- Sketchfab: filter downloadable and licences; prefer CC0 or CC-BY-compatible commercial use; attribute where required.
- BlenderKit: review asset-specific licence and terms.
- Poly Pizza: use only models whose individual licence supports intended distribution.
- Grab3D: check CC0 status at asset level and inspect model quality/format.
- Godot Asset Library: primarily reusable Godot addons, scripts and demos; not a substitute for realistic production assets.

## Integration workflow
- Inventory and licence record before download.
- Download source formats (GLB/glTF, FBX, OBJ only when appropriate); inspect in Blender.
- Reduce polygon count and texture sizes for Android; remove hidden geometry; bake materials where appropriate.
- Import into Godot and create reusable scenes.
- Test skeleton compatibility, animation retargeting, scale, orientation, collision and mobile performance.
- Do not include unlicensed, ripped, or trademark-specific models.
- Do not deliver an APK as a production-quality game while the critical asset checklist is empty.

## Asset ledger
Maintain per asset: name, source URL, creator, file format, licence, attribution requirements, modifications, import path, optimization status and verification notes.

## Current status
- Greybox prototype: available but explicitly temporary.
- Genuine production character/environment/vehicle assets: not yet integrated.
- Animation clips: not yet integrated as production assets.
- APK from greybox: prototype only; not a quality milestone.
