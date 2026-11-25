using UnityEngine;
public enum StreetLegendMissionStage{HotelCombat,DrivingPursuit,Roadblock,PostRoadblockCombat,Complete}
/// <summary>Single-authority phase gate. Car stop and combat handoff are explicit, idempotent.</summary>
public class StreetLegendMissionPhase:MonoBehaviour{
 public StreetLegendVehicleController vehicle;public GameObject drivingHUD,combatHUD;public PrototypeFighterController roadblockFighter;public Transform safeExitPoint;public StreetLegendMissionStage phase=StreetLegendMissionStage.HotelCombat;bool triggered;
 public void BeginPursuit(){if(phase!=StreetLegendMissionStage.HotelCombat)return;phase=StreetLegendMissionStage.DrivingPursuit;if(vehicle)vehicle.SetDrivingEnabled(true);if(drivingHUD)drivingHUD.SetActive(true);if(combatHUD)combatHUD.SetActive(false);}
 public void RoadblockReached(){if(phase!=StreetLegendMissionStage.DrivingPursuit||triggered)return;triggered=true;phase=StreetLegendMissionStage.Roadblock;if(vehicle){vehicle.StopVehicle();vehicle.SetDrivingEnabled(false);}if(drivingHUD)drivingHUD.SetActive(false);if(roadblockFighter){if(safeExitPoint)roadblockFighter.transform.position=safeExitPoint.position;roadblockFighter.enabled=true;}BeginRoadblockCombat();}
 public void BeginRoadblockCombat(){if(phase!=StreetLegendMissionStage.Roadblock)return;phase=StreetLegendMissionStage.PostRoadblockCombat;if(combatHUD)combatHUD.SetActive(true);}
 public void Finish(){if(phase==StreetLegendMissionStage.PostRoadblockCombat)phase=StreetLegendMissionStage.Complete;}
 public void ResetMission(){triggered=false;phase=StreetLegendMissionStage.HotelCombat;if(vehicle)vehicle.SetDrivingEnabled(false);if(drivingHUD)drivingHUD.SetActive(false);if(combatHUD)combatHUD.SetActive(true);}
}
