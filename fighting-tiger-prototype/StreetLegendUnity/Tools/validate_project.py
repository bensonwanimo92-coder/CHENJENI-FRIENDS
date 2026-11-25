#!/usr/bin/env python3
"""Fast structural checks for the Street Legend Unity starter project.

This does not replace Unity Editor compilation, Play Mode testing, or Android device QA.
"""
from pathlib import Path
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
        "PrototypeCommentatorManager", "CharacterController"
    ],
    "Assets/Scripts/PrototypeFighterController.cs": [
        "ResolveAttackAfterWindup", "PlayerHitConfirmed", "PlayerAttackMissed",
        "SetMobileMoveInput"
    ],
    "Assets/Scripts/PrototypeOpponent.cs": [
        "ChooseApproachDirection", "ResolveAttackAfterWindup", "ChooseApproachDirection", "OpponentStartedMoving", "OpponentDefeated"
    ],
    "Assets/Scripts/PrototypeMobileHUD.cs": [
        "ToggleVoice", "ToggleSubtitles", "SetMobileMoveInput", "fillAmount"
    ],
    "Assets/Scripts/PrototypeMatchManager.cs": [
        "FinishRound", "TogglePause", "RestartRound"
    ],
    "Assets/Scripts/PrototypeCommentatorManager.cs": [
        "TextToSpeech", "CreateDefaultLineSets", "SetSubtitlesEnabled", "spatialBlend = 0f"
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

if errors:
    print("STREET LEGEND STRUCTURAL CHECKS FAILED")
    for error in errors:
        print(" -", error)
    sys.exit(1)

print("STREET LEGEND STRUCTURAL CHECKS PASSED")
print(f"Checked {len(required)} required project files and {sum(map(len, checks.values()))} feature markers.")
print("Note: Unity compilation, scene generation, Play Mode physics and Android APK/device tests remain separate.")
