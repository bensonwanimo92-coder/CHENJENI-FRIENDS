using UnityEngine;
/// <summary>Camera visibility switcher for combat-to-driving mission phase transitions.</summary>
public class StreetLegendMissionCameraSwitcher:MonoBehaviour{
 public Camera combatCamera,drivingCamera;public StreetLegendMissionPhase mission;
 void LateUpdate(){if(!mission)return;bool drive=mission.phase==StreetLegendMissionStage.DrivingPursuit||mission.phase==StreetLegendMissionStage.Roadblock;if(combatCamera&&combatCamera.enabled==drive)combatCamera.enabled=!drive;if(drivingCamera&&drivingCamera.enabled!=drive)drivingCamera.enabled=drive;}
}
