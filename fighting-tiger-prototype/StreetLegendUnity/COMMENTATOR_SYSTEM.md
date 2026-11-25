# Street Legend — Commentator System

## Goal
Add an optional in-game fight commentator that makes matches feel energetic and broadcast-like without talking over every action.

## Voice and presentation
- Use an original commentator voice and original recorded or licensed voice lines.
- Support English first, with a Swahili voice pack as a later option.
- Keep the delivery confident, energetic and natural; avoid exaggerated or repetitive shouting.
- Add subtitle captions for every spoken line.
- Provide settings for commentator volume, subtitles and commentator on/off.

## Commentary events
The game should request a line only when a validated gameplay event occurs:
- Fight start: short match introduction.
- Clean confirmed hit: brief reaction.
- Heavy hit or combo milestone: stronger callout.
- Successful block, dodge or counter: tactical reaction.
- Knockdown: knockdown callout, followed by recovery commentary only if the fighter gets up.
- Round or mission result: win/loss summary.
- Boss encounter: unique introduction and defeat line.

## Anti-spam and accuracy rules
- Never announce a hit merely because an attack animation played.
- Trigger hit commentary only after the combat system confirms damage was applied.
- Do not play hit reactions for attacks blocked by walls, out of range, or facing away.
- Use event priorities: fight start/result and knockdown outrank ordinary hit reactions.
- Add cooldowns, duplicate-line prevention and a recent-line history.
- Do not interrupt important dialogue or play two voice lines simultaneously.
- If no suitable line is available, remain silent rather than play an incorrect line.

## Technical design
- Create a runtime `CommentatorManager` that receives typed combat and campaign events.
- Store lines in data assets (for example ScriptableObjects) with event type, priority, cooldown group, subtitle and audio clip.
- Use an audio source dedicated to commentary, separate from impacts, ambience and music.
- Use an audio pool/voice queue with priority-based interruption rules.
- Keep the system data-driven so additional languages and voice packs can be added without changing combat logic.
- Provide placeholder event hooks until final voice recordings are available.

## Android considerations
- Compress voice clips appropriately and load them by level or language pack.
- Avoid loading the entire commentary library into memory at once.
- Include settings to disable commentary and reduce audio memory use.

## Acceptance tests
1. A missed punch produces no hit commentary.
2. A punch blocked by a wall produces no hit commentary.
3. A confirmed hit produces one appropriate line at most.
4. Repeated hits do not spam the same line.
5. Knockdown commentary occurs only after a confirmed knockdown.
6. Commentary does not overlap critical story dialogue.
7. Disabling commentary silences it while combat sound effects remain active.
8. Subtitles match the line that actually plays.

## Current status
This document defines the feature. The runtime manager, audio assets, subtitles and in-game settings are not yet implemented or tested.
