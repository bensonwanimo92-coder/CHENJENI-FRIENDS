#!/usr/bin/env python3
"""Structural checks only; not Unity runtime/device QA."""
from pathlib import Path
import ast,json,sys
ROOT=Path(__file__).resolve().parents[1]
required=["ProjectSettings/ProjectVersion.txt","Packages/manifest.json","Assets/Editor/BuildHotelPrototype.cs","Assets/Editor/StreetLegendMenuSceneBuilder.cs","Assets/Scripts/StreetLegendMainMenu.cs","Assets/Editor/StreetLegendFighterAssetPipeline.cs","Assets/Editor/StreetLegendBuildTools.cs","Assets/Scripts/PrototypeFighterController.cs","Assets/Scripts/PrototypeOpponent.cs","Assets/Scripts/PrototypeMobileHUD.cs","Assets/Scripts/PrototypeMatchManager.cs","Assets/Scripts/PrototypeCommentatorManager.cs","Assets/Scripts/PrototypeHumanoidAnimationDriver.cs","Assets/Scripts/StreetLegendGameplayEvents.cs","Assets/Scripts/PrototypeCameraFollow.cs","Assets/Scripts/PrototypeFallRecovery.cs","Tools/Blender/generate_fighter_pair.py"]
errors=[f"Missing required file: {f}" for f in required if not (ROOT/f).is_file()]
p=ROOT/"Packages/manifest.json"
if p.exists():
 try:
  if "com.unity.ugui" not in json.loads(p.read_text()).get("dependencies",{}):errors.append("UGUI dependency missing")
 except Exception as ex:errors.append("Manifest invalid: "+str(ex))
checks={"Assets/Scripts/StreetLegendMainMenu.cs":["StreetLegend_MainMenu","Level1_Hotel_Prototype","LoadSceneAsync","PLAY CAMPAIGN","LandscapeLeft"],"Assets/Editor/StreetLegendMenuSceneBuilder.cs":["StreetLegend_MainMenu.unity","StreetLegendMainMenu"],"Assets/Editor/StreetLegendBuildTools.cs":["StreetLegend_MainMenu.unity","Level1_Hotel_Prototype.unity","BuildPlayerOptions"],"Assets/Scripts/PrototypeFighterController.cs":["ResolveAttackAfterWindup","PlayerHitConfirmed","PlayerAttackMissed","SetMobileMoveInput","HasClearAttackLine"],"Assets/Scripts/PrototypeOpponent.cs":["ChooseApproachDirection","ResolveAttackAfterWindup","guardChance","OpponentGuarded","RaiseAttackMiss"],"Assets/Scripts/PrototypeMobileHUD.cs":["ToggleVoice","ToggleSubtitles","SetMobileMoveInput","Virtual Joystick Base","Heavy Attack Button"],"Assets/Scripts/PrototypeMatchManager.cs":["FinishRound","TogglePause","RestartRound","MakeOverlayButton","RESUME","RESTART"],"Assets/Scripts/PrototypeCommentatorManager.cs":["TextToSpeech","CreateDefaultLineSets","SetSubtitlesEnabled"],"Assets/Scripts/PrototypeHumanoidAnimationDriver.cs":["StreetLegendGameplayEvents.Raised += HandleEvent","StreetLegendEventType.OpponentGuarded"]}
for f,markers in checks.items():
 if (ROOT/f).exists():
  src=(ROOT/f).read_text()
  errors.extend(f"{f} marker missing: {m}" for m in markers if m not in src)
b=ROOT/"Tools/Blender/generate_fighter_pair.py"
if b.exists():
 try:ast.parse(b.read_text())
 except SyntaxError as ex:errors.append("Blender syntax: "+str(ex))
if errors:print("CHECKS FAILED");print("\n".join(errors));sys.exit(1)
print("STRUCTURAL CHECKS PASSED. No Unity compilation, scene execution, or device testing implied.")
