# Street Legend — Physics, Geometry & Collision Quality Gate

These are mandatory gameplay acceptance rules, not optional polish. A scene is not ready for release merely because it looks correct.

## 1. Building and environment collision
- Every solid floor, wall, pillar, closed door, railing, stair edge and solid prop must have an appropriate non-trigger collider.
- Visual meshes and collision meshes must agree. Do not leave invisible gaps between wall segments or use oversized box colliders that block open doorways.
- Use simple box/capsule/convex colliders for static environment pieces wherever possible; avoid expensive MeshCollider use on moving objects.
- Doors must have a clear state: open means collider is moved/disabled; closed means the doorway is physically blocked.
- Add a scene validation pass that reports visible solid renderers without colliders and colliders with implausible bounds.
- CharacterControllers must collide with walls and props; never teleport fighters through geometry to apply hit knockback.

## 2. Floors, gravity and falling
- All playable floors need continuous collision coverage. Staircases and ramps need walkable collision surfaces and tested slope limits.
- Player and enemy controllers must apply gravity and reset downward velocity while grounded to keep contact with the floor.
- Falling below a defined kill/fail Y coordinate must trigger a recovery/checkpoint or defeat flow, never leave a character falling forever.
- Knockdowns must use an explicit grounded/knockdown/recovery state. Do not allow an unconscious fighter to keep sliding, hovering or standing instantly.
- For CharacterController characters, use controlled movement and grounded checks; do not mix Rigidbody forces with a CharacterController on the same root.

## 3. Combat must connect physically and visually
- An attack can damage only if it is inside range, inside the attack arc, during its active animation window, and has unobstructed line of sight.
- A fist or foot swinging into empty space must not damage or trigger a hit reaction on an opponent.
- Walls, pillars, closed doors and other solid objects must block attack rays/hit volumes.
- Hit reactions and pain audio are driven only by a confirmed damage event. No hit event means no opponent pain sound.
- Use animation events or timed hitbox windows for production combat. The current prototype uses a simple range/arc/raycast gate and is not a substitute for final animation-timed hitboxes.
- Prevent one swing from applying repeated damage every frame; each attack instance may hit a target only once unless a move explicitly defines multiple strikes.

## 4. Measurements and geometry conventions
- Unity world units are treated as metres for planning.
- Human placeholder capsule: approximately 1.8 m tall, radius 0.32–0.4 m; character controller dimensions must fit the visible model.
- Typical interior door clear width: approximately 0.9–1.1 m; corridor clear width: at least 1.5 m for combat movement; stair tread/riser dimensions must be consistent.
- Keep collision margins small and consistent. Avoid zero-thickness collision surfaces, overlapping floor slabs, inverted normals, non-uniformly scaled physics roots and negative scale.
- Use metric measurements, apply transforms where appropriate, and verify collider bounds in Scene view.

## 5. Camera and navigation
- Camera must not clip through walls or ceilings; add camera obstruction handling before final third-person camera work.
- Navigation routes must be physically traversable. AI must not path through walls or closed doors.
- Check narrow passages for CharacterController radius clearance and avoid corners that snag the player.
- Add ledges/guardrails where a player could otherwise walk off a high platform unintentionally.

## 6. Required test cases before calling a level playable
1. Walk into every wall from both sides: player and enemy remain outside the wall.
2. Walk through every doorway: open passages remain passable; closed doors block.
3. Walk across the whole floor, stairs and ramps: no gaps, sinking or floating.
4. Step off a ledge: gravity works and the fall/recovery rule activates.
5. Attack beyond range: no damage and no pain reaction.
6. Attack while facing away: no damage.
7. Attack with a wall/pillar between fighters: no damage.
8. Attack with a clear, correctly aimed hit: damage and reaction occur once.
9. Enemy attacks out of range or through a wall: player takes no damage.
10. Knockdown and recovery: fighter lands on the floor and returns to control only after the recovery state.
11. Repeat tests at low frame rate and on target Android hardware.

## 7. Current prototype limitations
The initial greybox uses primitive geometry with primitive colliders and CharacterControllers. Player and enemy attacks now have range, facing-arc and raycast obstruction checks; the enemy can damage player health. This code has not yet been compiled or tested in Unity. Animation-timed hit windows, robust knockdown states, ledge recovery, scene-wide collider auditing, navigation, camera collision and Android performance testing remain outstanding.

**Release gate:** Do not mark a scene complete or ship an APK until the above tests pass in Unity and on a real Android device.
