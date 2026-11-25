# Street Legend — Voice-Only Gameplay Commentator

## Core direction
The commentator is an unseen voice heard during gameplay. The commentator must never appear as a character, portrait, avatar, floating head, on-screen announcer, or visible gameplay object. The voice comes through the game's audio mix only. Optional subtitles may display the spoken words, but there is no visual commentator representation.

The commentator should narrate the player's gameplay broadly and naturally: not only major hits, but also meaningful movement, fighting decisions, reactions, exploration, interactions, mission progress and outcomes. It should feel like a live sports/action commentator following the player, with sensible context and natural phrasing.

## Voice and presentation
- Use an original commentator voice and original recorded or licensed voice lines.
- English first; design the system so a Swahili voice pack can be added.
- Energetic, expressive, conversational delivery with varied intensity. Use natural, familiar commentary phrasing rather than constant shouting.
- Commentary should have context and common-sense awareness: describe what is happening, why it matters, and the immediate result when the game has reliable information.
- Do not invent player actions, enemy reactions, damage, mission progress or environmental events.
- Do not speak on every frame or repeat a line for every tiny movement. Use event-driven narration with sensible pacing so it feels continuous without becoming irritating.
- Provide optional subtitles matching the actual voice line.
- Settings: commentator on/off, voice volume, subtitle on/off, and commentary frequency/intensity (relaxed, balanced, frequent).

## What the commentator should cover
### Player movement and traversal
- Starting to move, changing direction, running/sprinting, slowing down, jumping, landing, climbing or vaulting where supported.
- Approaching a doorway, entering a new area, navigating a narrow route, reaching a destination or encountering an obstacle.
- Falling, stumbling, being knocked down, getting back up and recovering.
- Avoid narrating every footstep; combine continuous movement into occasional contextual observations.

### Combat actions
- Starting a fight, approaching an opponent and changing combat stance where supported.
- Light/heavy punches, kicks, combinations, blocks, parries, dodges, counters, grabs, throws and special moves when those actions are actually performed.
- A missed attack, guarded attack, clean hit, heavy impact, interrupted combo, enemy attack, successful evade, knockdown and recovery.
- Stamina or health becoming critical, a tactical opening appearing, an opponent retreating or being defeated.
- Celebrate meaningful combos and finishing moves without claiming a hit unless damage or the relevant combat outcome is confirmed.

### World interaction and mission flow
- Opening doors, using objects, rescuing someone, collecting mission items, activating mechanisms and other supported interactions.
- Entering a new district or important location, discovering an objective, completing a task, reaching a checkpoint and mission success/failure.
- React to meaningful environmental changes only when the game reports them.

## Accuracy, pacing and priority
- All commentary must be driven by authoritative gameplay events from the movement, combat, interaction and campaign systems.
- Never announce a hit merely because an attack animation played. A hit callout requires confirmed hit/damage or a confirmed combat outcome.
- A missed punch may receive a contextual "that one missed" line, but must never be described as a successful hit.
- Attacks blocked by a wall, out of range or facing away must not trigger successful-hit commentary.
- Use event priorities: mission-critical events, knockdowns, finishing moves and results outrank routine movement observations.
- Add cooldowns, duplicate-line prevention, recent-line history and phrase variation.
- Avoid talking over important story dialogue, critical sound cues or another active commentator line.
- Use short gaps and occasional silence. Do not force a line when there is nothing useful to say.
- If the system lacks reliable event information, stay silent rather than guess.

## Technical design
- Implement a runtime `CommentatorManager` that listens to typed events from player movement, combat, interaction and campaign systems.
- Use data assets (for example ScriptableObjects) containing event type, priority, cooldown group, context tags, subtitle text, audio clip and variation group.
- Keep commentary audio on a dedicated mixer group, separate from music, ambience, dialogue and combat sound effects.
- Use a priority-aware voice queue; never overlap two commentator clips.
- Support context selection so lines account for player state, current mission, opponent state and recent commentary.
- Keep voice packs data-driven so new languages and recordings can be added without changing gameplay code.
- Do not create a visible commentator model or UI portrait. Subtitles are the only optional visual accompaniment.

## Android considerations
- Compress voice clips appropriately and load them by level or language pack.
- Avoid loading the entire commentary library into memory at once.
- Provide settings to disable commentary or reduce its frequency and audio memory use.

## Acceptance tests
1. No commentator character, portrait, avatar or visible announcer appears in gameplay.
2. The commentator can describe meaningful player actions across traversal, combat and mission progression.
3. Continuous movement does not create repetitive footstep-by-footstep speech.
4. A missed punch is never described as a successful hit.
5. A hit blocked by a wall, out of range or facing away produces no successful-hit callout.
6. A confirmed hit or combat event produces a suitable line without duplicate spam.
7. Commentary adapts to knockdowns, recovery, low health/stamina and mission outcomes only when those states are confirmed.
8. Commentary lines do not overlap one another or critical story dialogue.
9. Subtitles match the line actually played and can be disabled independently.
10. Turning commentary off leaves gameplay sound effects and music working normally.

## Current status
This document records the requested voice-only, broad gameplay narration design. The runtime manager, event hooks, audio recordings, subtitle integration and in-game settings are not yet implemented or tested.
