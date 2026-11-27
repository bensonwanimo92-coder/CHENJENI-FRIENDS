# Street Legend — four-level campaign implementation target

This branch must deliver a playable four-level story campaign. Level 1 is the opening, not the entire game.

## Campaign
1. **The Ambush:** hotel lobby combat, car pursuit, roadblock fight.
2. **The Pursuit:** city route tracking, alley ambushes, driving and street combat.
3. **The Hideout:** industrial compound infiltration, security fights and child/civilian rescue. The rescued child must not be an enemy target.
4. **The Reckoning:** final stronghold, phased lieutenant/boss encounter and campaign ending.

## System work
- Campaign progression/unlock/save logic in `scripts/campaign.gd`.
- Distinct mission scenes, environments, mission objectives, enemy waves and checkpoints per level.
- Campaign save persists completed/unlocked level state.
- Level select UI reflects unlock state and completed levels.
- Level transitions load actual mission scenes, not illustration cards.
- Mobile landscape controls, touch combat and driving remain consistent.
- Asset licensing and rigged character/environment/vehicle imports must be tracked separately from gameplay scaffolding.

## Integration gate
The campaign manager script is a scaffold. It is not integrated into project autoloads, level-selection UI or mission scenes until those files are inspected and updated. Do not claim playable Level 2–4 or an APK until CI/build confirms.
