# Street Legend — Child Rescue Sequence

## Intent
Odessa is a story-critical child NPC. The kidnapping/rescue sequence should communicate urgency and emotional stakes without graphic injury or making the child a combat target.

## Reactions when carried
- On grab: immediately trigger a startled vocal reaction and a short, non-graphic struggle animation (reach, twist, kick feet, try to pull free).
- While carried: play varied, contextual calls for help, with cooldowns and distance-aware audio; avoid looping the same line every few seconds.
- When the carrier moves away: gradually increase urgency and allow nearby witnesses to react (look toward the event, shout, seek cover or alert the player).
- Provide subtitles and mute/volume options consistent with the commentator settings.
- Never treat child voice cues as commentator sports narration; use a dedicated story voice cue/audio system.

## Rescue gameplay
- The child remains non-combatant and invulnerable; no attack hitboxes or damage states.
- Rescue is triggered by a validated interaction or completion of a scripted encounter, not by striking the child.
- After rescue: crying/struggling transitions to relief, child follows a safe escort path or a scripted handoff, with a short reunion beat.
- Fail states should be non-graphic and use a checkpoint/mission retry, not child injury imagery.

## Engineering notes
- Use a separate ChildStoryActor state machine with states: Safe, Grabbed, Carried, RescuePending, Rescued and Escorted.
- Use event-driven audio with per-line cooldowns and randomized variation. Keep a dedicated audio source with spatial audio and optional subtitles.
- Carrier and child transforms must be linked using a carry anchor; child colliders must not block the carrier or cause ragdoll instability.
- Validate carry attachment, floor clearance, collision layers, detach/rescue state, audio distance and cooldown behavior.
- Keep the sequence cinematic/scripted; do not imply the child can be used as a gameplay weapon or be harmed for rewards.

## Sample original voice cues (text placeholders)
- Initial grab: “Hey! Let me go!”
- Carried: “Help! Somebody help me!”
- Carried, farther away: “Dad! Where are you?”
- Rescue: “Dad!” / “You're here!”
- Witness: “Hey! Stop! Someone help!”