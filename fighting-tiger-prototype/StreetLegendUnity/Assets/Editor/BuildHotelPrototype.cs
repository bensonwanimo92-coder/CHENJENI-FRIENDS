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
        var player = Capsule("Wanimoo Prototype", new Vector3(-2,1,0), new Color(0.12f,0.42f,0.75f), true);
        var enemy = Capsule("Hotel Enforcer Prototype", new Vector3(2,1,4), new Color(0.62f,0.16f,0.13f), false);
        var pc = player.AddComponent<PrototypeFighterController>();
        var ai = enemy.AddComponent<PrototypeOpponent>();
        pc.SetOpponent(enemy.transform); ai.SetTarget(player.transform);
        if (!AssetDatabase.IsValidFolder("Assets/Scenes")) AssetDatabase.CreateFolder("Assets", "Scenes");
        var cameraObject = new GameObject("Prototype Camera");
        cameraObject.AddComponent<Camera>();
        var camera = cameraObject.AddComponent<PrototypeCameraFollow>();
        camera.target = player.transform;
        camera.transform.position = new Vector3(0,8,-10);
        camera.transform.rotation = Quaternion.Euler(35,0,0);
        var light = new GameObject("Hotel Key Light").AddComponent<Light>();
        light.type = LightType.Directional; light.intensity = 1.15f; light.transform.rotation = Quaternion.Euler(48,-28,0);
        Make("Lobby Reception", new Vector3(0,0.65f,8), new Vector3(5,1.3f,1), new Color(0.35f,0.22f,0.12f));
        Make("Lobby Column A", new Vector3(-6,2,6), new Vector3(0.7f,4,0.7f), new Color(0.55f,0.48f,0.38f));
        Make("Lobby Column B", new Vector3(6,2,6), new Vector3(0.7f,4,0.7f), new Color(0.55f,0.48f,0.38f));
        EditorSceneManager.SaveScene(scene, "Assets/Scenes/Level1_Hotel_Prototype.unity");
        Debug.Log("Street Legend hotel prototype scene created. Greybox art only; replace primitives with licensed character/environment assets.");
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
