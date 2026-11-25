# Street Legend — Leonida City gameplay map plan

This document defines the original, fictionalized Leonida-inspired gameplay layout. It is a city-inspired design, not a reproduction of any proprietary map or assets.

## Map design principles
- A continuous, navigable city block set with street-level scale and readable routes.
- Landmarks guide the player; routes must be traversable and collision-safe.
- A modular district approach supports streaming/mission expansion.
- Original buildings, street names, textures, signage, characters and layouts; inspiration only.
- Avoid invisible walls, impassable alleys, doors that look usable but are blocked, and gaps in floor geometry.
- The map must be measured in Unity units and validated against collision/navigation bounds before missions are playable.

## Initial gameplay geography
1. **Hotel District / Mission 1 — Hotel Escape**: hotel lobby, reception, lifts as blocked set dressing, side service exit, loading yard, curbside pickup zone. The initial fight stays in the lobby with a clear perimeter and escape route after the match.
2. **Downtown / Mission 2 — Backstreet Pursuit**: connected street grid, storefronts, alley shortcut, parking bays, road crossings and pursuit route; route markers and cover/obstacles are deliberate.
3. **Industrial Fringe / Mission 3 — Gang Hideout**: warehouses, service roads, fenced yard, safe entry route and alternate approach.
4. **Stronghold / Mission 4 — Slandon's Stronghold**: compound perimeter, gate, interior courtyard and multi-room progression; modular encounter spaces.
5. **Rescue / Odessa sequence**: scripted noncombatant rescue, no attacks on the child; witnesses react; reunion, escort, checkpoint and retry support.

## Street and traversal standards
- Each mission route includes a main path, at least one alternate path where appropriate, and clearly bounded playable areas.
- Use continuous ground collision, curb transitions and stairs/ramps with tested slope/step settings.
- Buildings have explicit solid collision volumes; decorative meshes must not create unexpected collider gaps or protrusions.
- Place doors and openings only when their interaction and collision are implemented; otherwise visually communicate that they are closed.
- Mark kill volumes/voids and use fall recovery with a clear checkpoint.
- AI navigation uses baked or verified navigation routes; do not assume a path is valid from a scene mesh alone.
- Camera zones avoid walls and ceilings; camera obstruction should preserve view of the player.

## Map build and QA gate
1. Establish coordinate grid, scale, ground and boundaries.
2. Block out district volumes and mission route.
3. Add collider-only geometry; test player and AI separately.
4. Check movement at corners, narrow passages, stairs, doors, obstacles and edges.
5. Verify pursuit/AI routes, line of sight and combat clearances.
6. Add visual dressing only after geometry tests pass.
7. Perform Unity scene and Play Mode checks, then Android hardware QA. Structural scripts alone do not certify geometry.

## First playable map scope
The first APK should contain a complete playable hotel lobby arena and the lobby escape route/adjacent exterior block, rather than pretending the whole city is already finished. Later districts expand as campaign chapters.
