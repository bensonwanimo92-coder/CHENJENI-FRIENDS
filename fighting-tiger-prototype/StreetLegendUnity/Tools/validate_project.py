#!/usr/bin/env python3
"""Fast structural checks for the Street Legend Unity starter project.

This does not replace Unity Editor compilation, Play Mode testing, or Android device QA.
"""
from pathlib import Path
import ast
import json
import sys

ROOT = Path(__file__).resolve().parents[1]
required = [
    "ProjectSettings/ProjectVersion.txt",
    "Packages/manifest.json",
    "Assets/Editor/BuildHotelPrototype.cs",
    "Assets/Editor/StreetLegendFighterAssetPipeline.cs",
    "Assets/Editor/StreetLegendBuildTools.cs",
    "Assets/Scripts/PrototypeFighterController.cs",
    "Assets/Scripts/PrototypeOpponent.cs",
    "Assets/Scripts/PrototypeMobileHUD.cs",
    "Assets/Scripts/PrototypeMatchManager.cs",
    "Assets/Scripts/PrototypeCommentatorManager.cs",
    "Assets/Scripts/PrototypeHumanoidAnimationDriver.cs",
    "Assets/Scripts/StreetLegendGameplayEvents.cs",
    "Assets/Scripts/PrototypeCameraFollow.cs",
    "Assets/Scripts/PrototypeFallRecovery.cs",
    "Tools/Blender/generate_fighter_pair.py",
]
errors = []
for item in required:
    if not (ROOT / item).is_file():
        errors.append(f"Missing required file: {item}")

manifest_path = ROOT / "Packages/manifest.json"
if manifest_path.exists():
    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        if "com.unity.ugui" not in manifest.get("dependencies", {}):
            errors.append("UGUI dependency is missing from Packages/manifest.json")
    except (json.JSONDecodeError, OSError) as exc:
        errors.append(f"Invalid package manifest: {exc}")

checks = {
    "Assets/Editor/BuildHotelPrototype.cs": [
        "Level1_Hotel_Prototype.unity", "PrototypeMobileHUD", "PrototypeMatchManager",
        "PrototypeCommentatorManager", "CharacterController", "UIOrientation.LandscapeLeft", "allowedAutorotateToLandscapeRight"
    ],
    "Assets/Scripts/PrototypeFighterController.cs": [
        "ResolveAttackAfterWindup", "PlayerHitConfirmed", "PlayerAttackMissed",
        "SetMobileMoveInput", "HasClearAttackLine", "Avoid stun-lock damage stacking"
    ],
    "Assets/Scripts/PrototypeOpponent.cs": [
        "ChooseApproachDirection", "ResolveAttackAfterWindup", "tacticalSwitchInterval", "circleSide", "retreatDistance", "OpponentStartedMoving", "OpponentDefeated", "HasClearAttackLine", "guardChance", "guardDamageMultiplier", "nextGuardAt", "OpponentGuarded", "guardStunDuration", "RaiseAttackMiss", "OpponentAttackMissed"
    ],
    "Assets/Scripts/PrototypeMobileHUD.cs": [
        "ToggleVoice", "ToggleSubtitles", "SetMobileMoveInput", "fillAmount", "Virtual Joystick Base", "Heavy Attack Button", "Pause Control", "touch-down"
    ],
    "Assets/Scripts/PrototypeMatchManager.cs": [
        "FinishRound", "TogglePause", "RestartRound", "MakeOverlayButton", "RESUME", "RESTART"
    ],
    "Assets/Scripts/PrototypeCommentatorManager.cs": [
        "TextToSpeech", "CreateDefaultLineSets", "SetSubtitlesEnabled", "spatialBlend = 0f"
    ],
    "Assets/Scripts/PrototypeHumanoidAnimationDriver.cs": [
        "bool moving", "moving ? \"Walk\" : \"Guard\"", "FallbackKnockoutPose",
        "StreetLegendGameplayEvents.Raised += HandleEvent", "StreetLegendEventType.OpponentGuarded"
    ],
    "Assets/Editor/StreetLegendFighterAssetPipeline.cs": [
        "defaultClipAnimations", "clips[i].loopTime", "clips[i].loopPose",
        "Prepare Fighter Prefabs", "Avatar.isHuman"
    ],
}
for filename, needles in checks.items():
    path = ROOT / filename
    if not path.exists():
        continue
    source = path.read_text(encoding="utf-8")
    for needle in needles:
        if needle not in source:
            errors.append(f"{filename} is missing expected feature marker: {needle}")

blender_script = ROOT / "Tools/Blender/generate_fighter_pair.py"
if blender_script.exists():
    try:
        ast.parse(blender_script.read_text(encoding="utf-8"))
    except SyntaxError as exc:
        errors.append(f"Blender generator has invalid Python syntax: {exc}")

if errors:
    print("STREET LEGEND STRUCTURAL CHECKS FAILED")
    for error in errors:
        print(" -", error)
    sys.exit(1)

print("STREET LEGEND STRUCTURAL CHECKS PASSED")
print(f"Checked {len(required)} required project files and {sum(map(len, checks.values()))} feature markers.")
print("Checked animation locomotion recovery and FBX loop import configuration.")
print("Note: Unity compilation, scene generation, Play Mode physics and Android APK/device tests remain separate.")
