using UnityEditor;
using UnityEngine;
using UnityEditor.SceneManagement;
using System.IO;

/// <summary>One-click editor bootstrap to reduce manual scene/setup steps.</summary>
public static class StreetLegendBootstrap
{
 [MenuItem("Street Legend/Setup Project Scenes (One Click)")]
 public static void Setup()
 {
  if (!EditorUtility.DisplayDialog("Street Legend Setup","Generate the main menu and hotel prototype scenes, then register them in Android build settings? This does not build an APK or run gameplay tests.","Setup","Cancel")) return;
  try {
   BuildHotelPrototype.Build();
   StreetLegendMenuSceneBuilder.Build();
   var menu="Assets/Scenes/StreetLegend_MainMenu.unity";
   var hotel="Assets/Scenes/Level1_Hotel_Prototype.unity";
   if(!File.Exists(menu)||!File.Exists(hotel)){Debug.LogError("Scene generation did not create both expected scenes.");return;}
   EditorBuildSettings.scenes=new[]{new EditorBuildSettingsScene(menu,true),new EditorBuildSettingsScene(hotel,true)};
   PlayerSettings.defaultInterfaceOrientation=UIOrientation.LandscapeLeft;
   PlayerSettings.allowedAutorotateToLandscapeLeft=true;PlayerSettings.allowedAutorotateToLandscapeRight=true;
   PlayerSettings.allowedAutorotateToPortrait=false;PlayerSettings.allowedAutorotateToPortraitUpsideDown=false;
   AssetDatabase.Refresh();
   EditorUtility.DisplayDialog("Street Legend","Setup complete: menu and hotel scenes generated and registered. Next: validate scene structure, then open Play Mode for manual checks.","OK");
   Debug.Log("Street Legend one-click setup completed. Scenes registered; Unity compilation and runtime QA still need to be performed.");
  } catch(System.Exception ex){Debug.LogError("Street Legend bootstrap failed: "+ex);}
 }
}