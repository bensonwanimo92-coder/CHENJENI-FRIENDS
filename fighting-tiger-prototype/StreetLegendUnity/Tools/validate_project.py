#!/usr/bin/env python3
"""Structural checks only; not Unity runtime QA or a Unity C# compiler."""
from pathlib import Path
import ast, json, sys
ROOT = Path(__file__).resolve().parents[1]
required = [
 "ProjectSettings/ProjectVersion.txt","Packages/manifest.json",
 "Assets/Editor/BuildHotelPrototype.cs","Assets/Editor/StreetLegendMenuSceneBuilder.cs",
 "Assets/Editor/StreetLegendBootstrap.cs","Assets/Scripts/StreetLegendMainMenu.cs",
 "Assets/Editor/StreetLegendFighterAssetPipeline.cs","Assets/Editor/StreetLegendBuildTools.cs",
 "Assets/Editor/StreetLegendCIBuild.cs",
 "Assets/Editor/StreetLegendPreBuildGate.cs","Assets/Editor/StreetLegendDrivingSceneBuilder.cs",
 "Assets/Editor/StreetLegendDrivingValidator.cs","Assets/Scripts/PrototypeFighterController.cs",
 "Assets/Scripts/PrototypeOpponent.cs","Assets/Scripts/PrototypeMobileHUD.cs",
 "Assets/Scripts/PrototypeMatchManager.cs","Assets/Scripts/PrototypeCommentatorManager.cs",
 "Assets/Scripts/PrototypeHumanoidAnimationDriver.cs","Assets/Scripts/StreetLegendGameplayEvents.cs",
 "Assets/Scripts/PrototypeCameraFollow.cs","Assets/Scripts/PrototypeFallRecovery.cs",
 "Assets/Scripts/StreetLegendVehicleController.cs","Assets/Scripts/StreetLegendChaseTarget.cs",
 "Assets/Scripts/StreetLegendDrivingHUD.cs","Assets/Scripts/StreetLegendMissionPhase.cs",
 "Assets/Scripts/StreetLegendRoadblockTrigger.cs","Assets/Scripts/StreetLegendMissionIntegrationDirector.cs",
 "Assets/Scripts/StreetLegendMissionCameraSwitcher.cs","Tools/Blender/generate_fighter_pair.py"
]
errors = [f"Missing required file: {f}" for f in required if not (ROOT/f).is_file()]
manifest = ROOT/"Packages/manifest.json"
if manifest.exists():
 try:
  deps=json.loads(manifest.read_text()).get("dependencies",{})
  if "com.unity.ugui" not in deps: errors.append("UGUI dependency missing")
 except Exception as ex: errors.append("Manifest invalid: "+str(ex))
checks = {
 "Assets/Scripts/StreetLegendMainMenu.cs":["STREET LEGEND","Level1_Hotel_Prototype","LoadSceneAsync","PLAY CAMPAIGN","LandscapeLeft"],
 "Assets/Editor/StreetLegendMenuSceneBuilder.cs":["StreetLegend_MainMenu.unity","StreetLegendMainMenu"],
 "Assets/Editor/StreetLegendBuildTools.cs":["StreetLegend_MainMenu.unity","Level1_Hotel_Prototype.unity","BuildPlayerOptions"],
 "Assets/Scripts/PrototypeFighterController.cs":["ResolveAttackAfterWindup","PlayerHitConfirmed","PlayerAttackMissed","SetMobileMoveInput","HasClearAttackLine"],
 "Assets/Scripts/PrototypeOpponent.cs":["ChooseApproachDirection","ResolveAttackAfterWindup","guardChance","OpponentGuarded","RaiseAttackMiss"],
 "Assets/Scripts/PrototypeMobileHUD.cs":["ToggleVoice","ToggleSubtitles","SetMobileMoveInput","Virtual Joystick Base","Heavy Attack Button"],
 "Assets/Scripts/PrototypeMatchManager.cs":["FinishRound","TogglePause","RestartRound","MakeOverlayButton","RESUME","RESTART"],
 "Assets/Scripts/PrototypeCommentatorManager.cs":["TextToSpeech","CreateDefaultLineSets","SetSubtitlesEnabled"],
 "Assets/Scripts/StreetLegendMissionPhase.cs":["DismountHandoff","Dismounting","PostRoadblockCombat","BuildOutcomeOverlay"],
 "Assets/Scripts/StreetLegendMissionIntegrationDirector.cs":["LaunchPursuit","BeginPursuit"],
 "Assets/Scripts/StreetLegendMissionCameraSwitcher.cs":["Dismounting","DrivingPursuit"],
 "Assets/Editor/StreetLegendPreBuildGate.cs":["Pre-Compilation Structural Gate","Level1_Hotel_Prototype.unity","Level1_Driving_Test.unity"],
 "Assets/Editor/StreetLegendCIBuild.cs":["StreetLegendCIBuild","BuildHotelPrototype.Build()","StreetLegendMenuSceneBuilder.Build()","BuildPipeline.BuildPlayer","StreetLegend.apk"]
}
for f,markers in checks.items():
 if (ROOT/f).exists():
  src=(ROOT/f).read_text()
  errors.extend(f"{f} marker missing: {m}" for m in markers if m not in src)
blender=ROOT/"Tools/Blender/generate_fighter_pair.py"
if blender.exists():
 try: ast.parse(blender.read_text())
 except SyntaxError as ex: errors.append("Blender syntax: "+str(ex))
if errors:
 print("CHECKS FAILED"); print("\n".join(errors)); sys.exit(1)
print("STRUCTURAL CHECKS PASSED. No Unity compilation or runtime/device testing implied.")
