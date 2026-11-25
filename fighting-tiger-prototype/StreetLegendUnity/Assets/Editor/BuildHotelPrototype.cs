using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

public static class BuildHotelPrototype
{
    [MenuItem("Street Legend/Build Hotel Prototype Scene")]
    public static void Build()
    {
        var scene = EditorSceneManager.NewScene(NewSceneSetup.EmptyScene, NewSceneMode.Single);
        RenderSettings.ambientLight = new Color(0.42f, 0.43f, 0.48f);
        Make("Hotel Floor", new Vector3(0,-0.25f,0), new Vector3(18,0.5f,24), new Color(0.24f,0.25f,0.28f));
        Make("Rear Hotel Wall", new Vector3(0,2,11.8f), new Vector3(18,4,0.4f), new Color(0.32f,0.29f,0.25f));
        Make("Left Hotel Wall", new Vector3(-8.8f,2,0), new Vector3(0.4f,4,24), new Color(0.32f,0.29f,0.25f));
        Make("Right Hotel Wall", new Vector3(8.8f,2,0), new Vector3(0.4f,4,24), new Color(0.32f,0.29f,0.25f));
        var player = CreateFighter("Wanimoo Player", "Wanimoo_Player", new Vector3(-2,0,0), new Color(0.12f,0.42f,0.75f));
        var enemy = CreateFighter("Hotel Enforcer", "Hotel_Enforcer", new Vector3(2,0,4), new Color(0.62f,0.16f,0.13f));
        var pc = player.AddComponent<PrototypeFighterController>();
        var ai = enemy.AddComponent<PrototypeOpponent>();
        player.AddComponent<PrototypeFallRecovery>();
        enemy.AddComponent<PrototypeFallRecovery>();
        pc.SetOpponent(enemy.transform); ai.SetTarget(player.transform);
        player.AddComponent<PrototypeMobileHUD>();
        if (!AssetDatabase.IsValidFolder("Assets/Scenes")) AssetDatabase.CreateFolder("Assets", "Scenes");
        var cameraObject = new GameObject("Prototype Camera");
        cameraObject.AddComponent<Camera>();
        var camera = cameraObject.AddComponent<PrototypeCameraFollow>();
        camera.target = player.transform;
        var commentatorObject = new GameObject("Voice-Only Commentator");
        commentatorObject.AddComponent<AudioSource>();
        commentatorObject.AddComponent<PrototypeCommentatorManager>();
        camera.transform.position = new Vector3(0,8,-10);
        camera.transform.rotation = Quaternion.Euler(35,0,0);
        var light = new GameObject("Hotel Key Light").AddComponent<Light>();
        light.type = LightType.Directional; light.intensity = 1.15f; light.transform.rotation = Quaternion.Euler(48,-28,0);
        Make("Lobby Reception", new Vector3(0,0.65f,8), new Vector3(5,1.3f,1), new Color(0.35f,0.22f,0.12f));
        Make("Lobby Column A", new Vector3(-6,2,6), new Vector3(0.7f,4,0.7f), new Color(0.55f,0.48f,0.38f));
        Make("Lobby Column B", new Vector3(6,2,6), new Vector3(0.7f,4,0.7f), new Color(0.55f,0.48f,0.38f));
        EditorSceneManager.SaveScene(scene, "Assets/Scenes/Level1_Hotel_Prototype.unity");
        Debug.Log("Street Legend hotel prototype scene created. Generated fighter prefabs are used when available; otherwise coloured capsule placeholders are used. Environment remains greybox geometry.");
    }

    static GameObject CreateFighter(string displayName, string assetName, Vector3 position, Color fallbackColor)
    {
        string prefabPath = "Assets/Characters/Prefabs/" + assetName + ".prefab";
        GameObject prefab = AssetDatabase.LoadAssetAtPath<GameObject>(prefabPath);
        bool usingGeneratedPrefab = prefab != null;
        GameObject fighter = usingGeneratedPrefab
            ? PrefabUtility.InstantiatePrefab(prefab) as GameObject
            : Capsule(displayName + " Placeholder", position + Vector3.up, fallbackColor, assetName == "Wanimoo_Player");

        if (!fighter) throw new System.InvalidOperationException("Could not create fighter: " + displayName);
        fighter.name = displayName;
        if (usingGeneratedPrefab) fighter.transform.position = position;
        if (!fighter.GetComponent<CharacterController>())
        {
            var controller = fighter.AddComponent<CharacterController>();
            controller.height = 1.85f;
            controller.radius = 0.31f;
            controller.center = new Vector3(0f, 0.93f, 0f);
            controller.skinWidth = 0.035f;
        }
        var animator = fighter.GetComponent<Animator>();
        if (prefab && !animator)
            animator = fighter.AddComponent<Animator>();
        if (animator) animator.applyRootMotion = false;
        return fighter;
    }

    static GameObject Make(string name, Vector3 pos, Vector3 scale, Color color)
    {
        var go = GameObject.CreatePrimitive(PrimitiveType.Cube); go.name=name; go.transform.position=pos; go.transform.localScale=scale;
        go.GetComponent<Renderer>().sharedMaterial = Material(color); return go;
    }
    static GameObject Capsule(string name, Vector3 pos, Color color, bool player)
    {
        var go=GameObject.CreatePrimitive(PrimitiveType.Capsule); go.name=name; go.transform.position=pos;
        go.GetComponent<Renderer>().sharedMaterial=Material(color);
        go.AddComponent<CharacterController>();
        return go;
    }
    static Material Material(Color c) { var m=new Material(Shader.Find("Standard")); m.color=c; return m; }
}
