using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

public static class BuildHotelPrototype
{
    [MenuItem("Street Legend/Build Hotel Prototype Scene")]
    public static void Build()
    {
        // Street Legend is designed as a landscape fighting game (PES-style), not portrait.
        PlayerSettings.defaultInterfaceOrientation = UIOrientation.LandscapeLeft;
        PlayerSettings.allowedAutorotateToLandscapeLeft = true;
        PlayerSettings.allowedAutorotateToLandscapeRight = true;
        PlayerSettings.allowedAutorotateToPortrait = false;
        PlayerSettings.allowedAutorotateToPortraitUpsideDown = false;
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
        var matchManager = new GameObject("Match Manager").AddComponent<PrototypeMatchManager>();
        matchManager.SetFighters(pc, ai);
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
        // Mission integration scaffold: the car is staged outside and activated only after the hotel opponent is KO.
        var vehicleRoot = new GameObject("Wanimo Pursuit Vehicle");
        vehicleRoot.transform.position = new Vector3(0,1,-18);
        var vehicleBody = Make("Vehicle Body Placeholder", new Vector3(0,1.5f,-18), new Vector3(2,1,4), new Color(0.12f,0.3f,0.72f));
        vehicleBody.transform.SetParent(vehicleRoot.transform,true);
        Object.DestroyImmediate(vehicleBody.GetComponent<BoxCollider>());
        var vehicleCollider=vehicleRoot.AddComponent<BoxCollider>();vehicleCollider.size=new Vector3(2,1,4);vehicleCollider.center=new Vector3(0,.5f,0);
        var vehicleRb=vehicleRoot.AddComponent<Rigidbody>();vehicleRb.mass=1300;vehicleRb.centerOfMass=new Vector3(0,-.45f,0);
        var vehicleController=vehicleRoot.AddComponent<StreetLegendVehicleController>();
        var chaseTarget=new GameObject("Range Rover Chase Target");chaseTarget.transform.position=new Vector3(3,1,-2);
        var chaseBody=Make("Range Rover Placeholder",new Vector3(3,1.5f,-2),new Vector3(2,1,4),new Color(.12f,.12f,.15f));chaseBody.transform.SetParent(chaseTarget.transform,true);Object.DestroyImmediate(chaseBody.GetComponent<BoxCollider>());
        chaseTarget.AddComponent<BoxCollider>();chaseTarget.AddComponent<Rigidbody>().isKinematic=true;var targetDrive=chaseTarget.AddComponent<StreetLegendChaseTarget>();
        var chaseRoute=new Transform[3];for(int i=0;i<3;i++){var wp=new GameObject("Pursuit Route "+i);wp.transform.position=new Vector3(i==1?4:-3,1,25+i*22);chaseRoute[i]=wp.transform;}targetDrive.route=chaseRoute;
        Make("Pursuit Road",new Vector3(0,-.25f,30),new Vector3(18,.5f,100),new Color(.22f,.22f,.23f));
        Make("Roadblock Barrier",new Vector3(0,1,70),new Vector3(12,2,1),Color.yellow);
        var rbTrigger=new GameObject("Roadblock Trigger");rbTrigger.transform.position=new Vector3(0,1,64);var rbBox=rbTrigger.AddComponent<BoxCollider>();rbBox.isTrigger=true;rbBox.size=new Vector3(18,3,8);var rbLogic=rbTrigger.AddComponent<StreetLegendRoadblockTrigger>();
        vehicleRoot.SetActive(false);
        // Separate roadblock opponent avoids reusing the KO hotel enemy.
        var roadblockEnemy=CreateFighter("Roadblock Enforcer","Roadblock_Enforcer",new Vector3(2,0,66),new Color(0.58f,0.16f,0.12f));
        var roadblockAi=roadblockEnemy.AddComponent<PrototypeOpponent>();roadblockEnemy.AddComponent<PrototypeFallRecovery>();roadblockAi.SetTarget(player.transform);roadblockEnemy.SetActive(false);
        var missionPhase=new GameObject("Mission Phase Coordinator").AddComponent<StreetLegendMissionPhase>();missionPhase.vehicle=vehicleController;missionPhase.player=pc;missionPhase.roadblockFighter=roadblockEnemy.GetComponent<PrototypeFighterController>();missionPhase.roadblockOpponent=roadblockAi;missionPhase.safeExitPoint=new GameObject("Roadblock Player Exit").transform;missionPhase.safeExitPoint.position=new Vector3(-2,0,62);missionPhase.roadblockOpponentPoint=new GameObject("Roadblock Enemy Spawn").transform;missionPhase.roadblockOpponentPoint.position=new Vector3(2,0,66);
        var drivingUiRoot=new GameObject("Driving HUD");var drivingHud=drivingUiRoot.AddComponent<StreetLegendDrivingHUD>();drivingHud.vehicle=vehicleController;drivingUiRoot.SetActive(false);missionPhase.drivingHUD=drivingUiRoot;rbLogic.mission=missionPhase;
        var director=new GameObject("Hotel Pursuit Integration").AddComponent<StreetLegendMissionIntegrationDirector>();director.hotelOpponent=ai;director.mission=missionPhase;director.vehicle=vehicleController;director.drivingHud=drivingHud;director.vehicleEntryPoint=vehicleRoot.transform;director.hotelPlayer=pc;director.hotelMatchManager=matchManager;director.hotelCombatHud=player.GetComponent<PrototypeMobileHUD>();
        var driveCamObj=new GameObject("Pursuit Camera");var driveCam=driveCamObj.AddComponent<Camera>();driveCamObj.AddComponent<StreetLegendDrivingCamera>().target=vehicleRoot.transform;driveCam.enabled=false;
        // Camera mode switcher listens for mission phase changes and toggles the camera.
        driveCamObj.AddComponent<StreetLegendMissionCameraSwitcher>().combatCamera=cameraObject.GetComponent<Camera>();driveCamObj.GetComponent<StreetLegendMissionCameraSwitcher>().drivingCamera=driveCam;driveCamObj.GetComponent<StreetLegendMissionCameraSwitcher>().mission=missionPhase;
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
        // Primitive capsules carry a collider; remove it to avoid duplicate collision surfaces
        // when the CharacterController is added and tuned for gameplay.
        Object.DestroyImmediate(go.GetComponent<CapsuleCollider>());
        var controller = go.AddComponent<CharacterController>();
        controller.height = 1.85f;
        controller.radius = 0.31f;
        controller.center = new Vector3(0f, 0.93f, 0f);
        controller.skinWidth = 0.035f;
        return go;
    }
    static Material Material(Color c) { var m=new Material(Shader.Find("Standard")); m.color=c; return m; }
}
