using UnityEditor;
using UnityEngine;
using System.IO;

/// <summary>Pre-build structural gate. Does not replace Unity compilation or gameplay QA.</summary>
public static class StreetLegendPreBuildGate
{
 [MenuItem("Street Legend/Pre-Compilation Structural Gate")]
 public static void Run()
 {
  int errors=0, warnings=0;
  string[] required={
   "Assets/Scripts/PrototypeFighterController.cs","Assets/Scripts/PrototypeOpponent.cs",
   "Assets/Scripts/PrototypeMatchManager.cs","Assets/Scripts/PrototypeMobileHUD.cs",
   "Assets/Scripts/PrototypeCommentatorManager.cs","Assets/Scripts/StreetLegendVehicleController.cs",
   "Assets/Scripts/StreetLegendChaseTarget.cs","Assets/Scripts/StreetLegendDrivingHUD.cs",
   "Assets/Scripts/StreetLegendMissionPhase.cs","Assets/Scripts/StreetLegendRoadblockTrigger.cs",
   "Assets/Editor/BuildHotelPrototype.cs","Assets/Editor/StreetLegendDrivingSceneBuilder.cs",
   "Assets/Editor/StreetLegendDrivingValidator.cs"
  };
  foreach(string p in required){if(!File.Exists(p)){Debug.LogError("Missing required source: "+p);errors++;}}
  if(PlayerSettings.defaultInterfaceOrientation!=UIOrientation.LandscapeLeft){Debug.LogWarning("Default orientation is not Landscape Left.");warnings++;}
  if(EditorBuildSettings.scenes.Length==0){Debug.LogWarning("No scenes registered in Build Settings. Run Setup Project Scenes (One Click).");warnings++;}
  bool menu=false,hotel=false;
  foreach(var s in EditorBuildSettings.scenes){if(!s.enabled)continue;if(s.path.Contains("StreetLegend_MainMenu"))menu=true;if(s.path.Contains("Level1_Hotel"))hotel=true;}
  if(!menu) {Debug.LogWarning("Main menu scene is not registered/enabled in Build Settings.");warnings++;}
  if(!hotel){Debug.LogWarning("Hotel prototype scene is not registered/enabled in Build Settings.");warnings++;}
  if(!File.Exists("Assets/Scenes/Level1_Driving_Test.unity")){Debug.LogWarning("Driving test scene asset not generated yet. Run Street Legend/Build Driving Chase Test Scene.");warnings++;}
  if(errors==0)Debug.Log("Structural gate: required source-file presence checks passed. Warnings: "+warnings+". This is not a compile/build/runtime test.");
  else Debug.LogError("Structural gate failed: "+errors+" missing source item(s), "+warnings+" warning(s).");
 }
}
