# CombatMoveSet integration

Attach to player or enemy root and assign the Animator. Populate Move entries in the Inspector with Animator triggers, stamina cost, cooldown and damage. Connect touch buttons to ExecuteMove(index). Add animation event-driven hit windows and hitbox activation separately so damage occurs only during the move's active frames. The script is a combat control bridge, not a complete animation or collision implementation.
