# Hit reactions and smarter opponents

## HitReactionController
Add this component to the fighter root and assign an Animator and optional non-kinematic Rigidbody. Call `ReactToHit(damage, direction)` from the damage/impact event. Animator trigger names default to `HitLight`, `HitHeavy`, and `Knockdown`; create matching triggers or change these fields. Damage thresholds are configurable in code.

Use layered animation blending and short reaction clips for light hits, heavier stagger clips for larger hits, and a knockdown/recovery sequence for knockdowns. Avoid applying physics impulse and root-motion knockback simultaneously.

## EnemyCombatTactics
This optional tactical layer gives opponents a guard/recovery state and random timing. It is not a complete replacement for EnemyCombatAI. Assign player and Animator; create `Guard` and `Recover` bools if using the default names. Connect attack-finished animation events to `NotifyAttackFinished()`.

## Desired combat behavior
- Incoming hits cause visible stagger and body recoil rather than damage-only subtraction.
- Heavy hits interrupt an attack when the combat design permits.
- Opponent guard decisions should be timed and limited, not constant.
- Knockdowns require recovery animation and temporary vulnerability.
- Hit detection should be directional and use attack-specific timing windows.
- No animation or physics test has yet been performed in the Unity editor.
