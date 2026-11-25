using System;
using System.IO;
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEditor.SceneManagement;
using UnityEngine;

/// <summary>
/// Non-interactive CI entry point. Generates the campaign scenes before building,
/// because generated scenes are intentionally not committed as hand-authored assets.
/// </summary>
public static class StreetLegendCIBuild
{
    private const string MenuScene = "Assets/Scenes/StreetLegend_MainMenu.unity";
    private const string HotelScene = "Assets/Scenes/Level1_Hotel_Prototype.unity";
    private const string OutputPath = "build/Android/StreetLegend.apk";

    public static void PerformBuild()
    {
        try
        {
            Debug.Log("Street Legend CI: generating campaign scenes.");
            BuildHotelPrototype.Build();
            StreetLegendMenuSceneBuilder.Build();

            if (!File.Exists(MenuScene) || !File.Exists(HotelScene))
                throw new FileNotFoundException("Scene generation did not create both required campaign scenes.");

            EditorBuildSettings.scenes = new[]
            {
                new EditorBuildSettingsScene(MenuScene, true),
                new EditorBuildSettingsScene(HotelScene, true)
            };

            PlayerSettings.defaultInterfaceOrientation = UIOrientation.LandscapeLeft;
            PlayerSettings.allowedAutorotateToLandscapeLeft = true;
            PlayerSettings.allowedAutorotateToLandscapeRight = true;
            PlayerSettings.allowedAutorotateToPortrait = false;
            PlayerSettings.allowedAutorotateToPortraitUpsideDown = false;
            PlayerSettings.Android.targetArchitectures = AndroidArchitecture.ARM64;
            PlayerSettings.productName = "Street Legend";
            PlayerSettings.companyName = "SkyNest Studios";

            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
            EditorSceneManager.SaveOpenScenes();

            Directory.CreateDirectory(Path.GetDirectoryName(OutputPath));
            var options = new BuildPlayerOptions
            {
                scenes = new[] { MenuScene, HotelScene },
                locationPathName = OutputPath,
                target = BuildTarget.Android,
                options = BuildOptions.None
            };

            Debug.Log("Street Legend CI: compiling scripts and building Android APK.");
            BuildReport report = BuildPipeline.BuildPlayer(options);
            Debug.Log("Street Legend CI build result: " + report.summary.result +
                      "; errors=" + report.summary.totalErrors +
                      "; warnings=" + report.summary.totalWarnings +
                      "; output=" + OutputPath);

            EditorApplication.Exit(report.summary.result == BuildResult.Succeeded ? 0 : 1);
        }
        catch (Exception exception)
        {
            Debug.LogException(exception);
            EditorApplication.Exit(1);
        }
    }
}
