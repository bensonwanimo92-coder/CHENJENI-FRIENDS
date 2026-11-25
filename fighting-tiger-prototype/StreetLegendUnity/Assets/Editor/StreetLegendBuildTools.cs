using System.IO;
using UnityEditor;
using UnityEditor.Build.Reporting;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

public static class StreetLegendBuildTools
{
    const string ScenePath = "Assets/Scenes/Level1_Hotel_Prototype.unity";
    const string OutputPath = "Builds/Android/StreetLegend.apk";

    [MenuItem("Street Legend/Validate Hotel Prototype")]
    public static void ValidateHotelPrototype()
    {
        if (!File.Exists(ScenePath))
        {
            Debug.LogError("Hotel scene is missing. Run Street Legend > Build Hotel Prototype Scene first.");
            return;
        }

        EditorSceneManager.OpenScene(ScenePath, OpenSceneMode.Single);
        int errors = 0;
        errors += RequireObject("Wanimoo Player", typeof(PrototypeFighterController), typeof(CharacterController), typeof(PrototypeMobileHUD));
        errors += RequireObject("Hotel Enforcer", typeof(PrototypeOpponent), typeof(CharacterController));
        errors += RequireObject("Prototype Camera", typeof(Camera), typeof(PrototypeCameraFollow));
        errors += RequireObject("Voice-Only Commentator", typeof(PrototypeCommentatorManager), typeof(AudioSource));
        errors += RequireObject("Match Manager", typeof(PrototypeMatchManager));
        errors += RequireObject("Hotel Floor", typeof(Collider));
        errors += RequireObject("Rear Hotel Wall", typeof(Collider));
        errors += RequireObject("Left Hotel Wall", typeof(Collider));
        errors += RequireObject("Right Hotel Wall", typeof(Collider));

        if (errors == 0)
            Debug.Log("STREET LEGEND VALIDATION PASSED: scene objects, combat controllers, HUD, match flow, commentator and core collision geometry are present. This is a scene-structure check, not a Play Mode or device test.");
        else
            Debug.LogError("STREET LEGEND VALIDATION FAILED: " + errors + " required scene checks failed.");
    }

    static int RequireObject(string objectName, params System.Type[] requiredComponents)
    {
        GameObject go = GameObject.Find(objectName);
        if (!go)
        {
            Debug.LogError("Missing scene object: " + objectName);
            return 1;
        }

        int errors = 0;
        foreach (System.Type type in requiredComponents)
        {
            if (!go.GetComponent(type))
            {
                Debug.LogError(objectName + " is missing component " + type.Name);
                errors++;
            }
        }
        return errors;
    }

    [MenuItem("Street Legend/Build Android APK")]
    public static void BuildAndroidApk()
    {
        if (!File.Exists(ScenePath))
        {
            EditorUtility.DisplayDialog("Street Legend", "Build the hotel prototype scene first.", "OK");
            return;
        }

        if (EditorUserBuildSettings.activeBuildTarget != BuildTarget.Android)
        {
            bool switched = EditorUserBuildSettings.SwitchActiveBuildTarget(BuildTargetGroup.Android, BuildTarget.Android);
            if (!switched)
            {
                EditorUtility.DisplayDialog("Street Legend", "Android Build Support is not installed in this Unity Editor. Install Android Build Support, SDK, NDK and OpenJDK through Unity Hub.", "OK");
                return;
            }
        }

        string directory = Path.GetDirectoryName(OutputPath);
        if (!Directory.Exists(directory)) Directory.CreateDirectory(directory);

        EditorBuildSettings.scenes = new[]
        {
            new EditorBuildSettingsScene(ScenePath, true)
        };

        PlayerSettings.Android.targetArchitectures = AndroidArchitecture.ARM64;
        var options = new BuildPlayerOptions
        {
            scenes = new[] { ScenePath },
            locationPathName = OutputPath,
            target = BuildTarget.Android,
            options = BuildOptions.None
        };

        BuildReport report = BuildPipeline.BuildPlayer(options);
        if (report.summary.result == BuildResult.Succeeded)
        {
            Debug.Log("STREET LEGEND ANDROID BUILD SUCCEEDED: " + Path.GetFullPath(OutputPath) +
                " (" + report.summary.totalSize + " bytes). Install and test on a real Android device before release.");
            EditorUtility.RevealInFinder(OutputPath);
        }
        else
        {
            Debug.LogError("STREET LEGEND ANDROID BUILD FAILED: " + report.summary.result +
                ". Check the full Unity Console and Build Report for errors.");
        }
    }
}
