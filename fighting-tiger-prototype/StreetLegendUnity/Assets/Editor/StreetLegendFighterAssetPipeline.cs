using System.IO;
using UnityEditor;
using UnityEditor.Animations;
using UnityEngine;

/// <summary>
/// Applies consistent Humanoid import settings and creates reusable fighter prefabs
/// from the two Blender-generated base FBX files.
/// </summary>
public class StreetLegendFighterAssetPipeline : AssetPostprocessor
{
    const string GeneratedFolder = "Assets/Characters/Generated";
    const string PrefabFolder = "Assets/Characters/Prefabs";
    const string ControllerFolder = "Assets/Characters/Controllers";

    void OnPreprocessModel()
    {
        if (!assetPath.StartsWith(GeneratedFolder + "/") || !assetPath.EndsWith(".fbx"))
            return;

        var importer = (ModelImporter)assetImporter;
        importer.globalScale = 1f;
        importer.importCameras = false;
        importer.importLights = false;
        importer.importAnimation = true;
        importer.animationType = ModelImporterAnimationType.Human;
        importer.avatarSetup = ModelImporterAvatarSetup.CreateFromThisModel;
        importer.optimizeGameObjects = false;
        importer.importBlendShapes = true;
        importer.meshCompression = ModelImporterMeshCompression.Medium;
        importer.materialImportMode = ModelImporterMaterialImportMode.ImportStandard;
    }

    [MenuItem("Street Legend/Characters/Prepare Fighter Prefabs")]
    public static void PreparePrefabs()
    {
        if (!AssetDatabase.IsValidFolder("Assets/Characters"))
            AssetDatabase.CreateFolder("Assets", "Characters");
        if (!AssetDatabase.IsValidFolder(PrefabFolder))
            AssetDatabase.CreateFolder("Assets/Characters", "Prefabs");
        if (!AssetDatabase.IsValidFolder(ControllerFolder))
            AssetDatabase.CreateFolder("Assets/Characters", "Controllers");

        string[] names = { "Wanimoo_Player", "Hotel_Enforcer" };
        int created = 0;
        foreach (string name in names)
        {
            string modelPath = GeneratedFolder + "/" + name + ".fbx";
            var model = AssetDatabase.LoadAssetAtPath<GameObject>(modelPath);
            if (!model)
            {
                Debug.LogError("Missing fighter FBX: " + modelPath +
                    ". Run the Blender generator and copy its exports into Assets/Characters/Generated.");
                continue;
            }

            var importer = AssetImporter.GetAtPath(modelPath) as ModelImporter;
            if (importer == null || importer.animationType != ModelImporterAnimationType.Human)
            {
                Debug.LogError("Fighter is not configured as Humanoid: " + modelPath);
                continue;
            }

            Avatar humanoidAvatar = null;
            Object[] importedAssets = AssetDatabase.LoadAllAssetsAtPath(modelPath);
            foreach (Object importedAsset in importedAssets)
            {
                if (importedAsset is Avatar candidate)
                {
                    humanoidAvatar = candidate;
                    break;
                }
            }
            if (!humanoidAvatar || !humanoidAvatar.isValid || !humanoidAvatar.isHuman)
            {
                Debug.LogError("Humanoid Avatar mapping is invalid for " + modelPath +
                    ". Open the FBX Rig tab, configure the bone mapping, and Apply.");
                continue;
            }

            var instance = PrefabUtility.InstantiatePrefab(model) as GameObject;
            if (!instance) continue;
            instance.name = name;
            var animator = instance.GetComponent<Animator>();
            if (!animator) animator = instance.AddComponent<Animator>();
            animator.avatar = humanoidAvatar;
            animator.applyRootMotion = false;
            RuntimeAnimatorController generatedController = BuildAnimationController(name, importedAssets);
            if (generatedController) animator.runtimeAnimatorController = generatedController;
            var animationDriver = instance.GetComponent<PrototypeHumanoidAnimationDriver>();
            if (!animationDriver) animationDriver = instance.AddComponent<PrototypeHumanoidAnimationDriver>();

            // The CharacterController belongs on the fighter root, not on individual body parts.
            var controller = instance.GetComponent<CharacterController>();
            if (!controller) controller = instance.AddComponent<CharacterController>();
            controller.height = 1.85f;
            controller.radius = 0.31f;
            controller.center = new Vector3(0f, 0.93f, 0f);
            controller.skinWidth = 0.035f;
            controller.minMoveDistance = 0f;

            string prefabPath = PrefabFolder + "/" + name + ".prefab";
            PrefabUtility.SaveAsPrefabAsset(instance, prefabPath);
            Object.DestroyImmediate(instance);
            created++;
            Debug.Log("Prepared Humanoid fighter prefab: " + prefabPath);
        }

        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
        Debug.Log("Street Legend fighter pipeline: " + created + "/2 prefabs prepared. Verify the imported Avatar and test each generated animation state in Play Mode before gameplay use.");
    }

    static RuntimeAnimatorController BuildAnimationController(string fighterName, Object[] importedAssets)
    {
        string controllerPath = ControllerFolder + "/" + fighterName + "_Controller.controller";
        if (AssetDatabase.LoadAssetAtPath<AnimatorController>(controllerPath))
            AssetDatabase.DeleteAsset(controllerPath);

        AnimatorController controller = AnimatorController.CreateAnimatorControllerAtPath(controllerPath);
        AnimatorStateMachine machine = controller.layers[0].stateMachine;
        int importedCount = 0;
        foreach (Object asset in importedAssets)
        {
            AnimationClip clip = asset as AnimationClip;
            if (!clip || clip.name.StartsWith("__preview__")) continue;
            string lower = clip.name.ToLowerInvariant();
            string stateName = null;
            if (lower.Contains("sl_idle")) stateName = "Idle";
            else if (lower.Contains("sl_guard")) stateName = "Guard";
            else if (lower.Contains("sl_jab")) stateName = "Jab";
            else if (lower.Contains("sl_heavykick")) stateName = "HeavyKick";
            else if (lower.Contains("sl_hitreact")) stateName = "HitReact";
            else if (lower.Contains("sl_knockout")) stateName = "Knockout";
            if (stateName == null || machine.states.Length > 0 && System.Array.Exists(machine.states, s => s.state.name == stateName))
                continue;

            AnimatorState state = machine.AddState(stateName);
            state.motion = clip;
            if (stateName == "Idle") machine.defaultState = state;
            importedCount++;
        }

        if (importedCount == 0)
        {
            AssetDatabase.DeleteAsset(controllerPath);
            Debug.LogWarning("No Street Legend animation takes were found in " + fighterName +
                ". The Humanoid prefab will still be created, but it will need animation clips before it can move naturally.");
            return null;
        }

        if (machine.defaultState == null && machine.states.Length > 0)
            machine.defaultState = machine.states[0].state;
        Debug.Log("Created " + importedCount + " animation states for " + fighterName + ": " + controllerPath);
        return controller;
    }
}
