using UnityEngine;
public enum StreetLegendMissionStage{HotelCombat,DrivingPursuit,Roadblock,PostRoadblockCombat,Complete}
/// <summary>Phase authority for the Level 1 hotel escape, driving pursuit and roadblock encounter.</summary>
public class StreetLegendMissionPhase:MonoBehaviour{
 public StreetLegendVehicleController vehicle; public GameObject drivingHUD,combatHUD;
 public PrototypeFighterController player,roadblockFighter; public PrototypeOpponent roadblockOpponent;
 public Transform safeExitPoint,roadblockOpponentPoint;
 public StreetLegendMissionStage phase=StreetLegendMissionStage.HotelCombat; bool triggered;
 public void BeginPursuit(){if(phase!=StreetLegendMissionStage.HotelCombat)return;phase=StreetLegendMissionStage.DrivingPursuit;if(vehicle){vehicle.gameObject.SetActive(true);vehicle.SetDrivingEnabled(true);}if(drivingHUD)drivingHUD.SetActive(true);if(combatHUD)combatHUD.SetActive(false);}
 public void RoadblockReached(){if(phase!=StreetLegendMissionStage.DrivingPursuit||triggered)return;triggered=true;phase=StreetLegendMissionStage.Roadblock;if(vehicle){vehicle.StopVehicle();vehicle.SetDrivingEnabled(false);}if(drivingHUD)drivingHUD.SetActive(false);
 if(player){player.transform.position=safeExitPoint?safeExitPoint.position:player.transform.position;player.ResetVerticalMotion();player.enabled=true;}
 if(roadblockFighter){roadblockFighter.gameObject.SetActive(true);if(roadblockOpponentPoint)roadblockFighter.transform.position=roadblockOpponentPoint.position;roadblockFighter.enabled=true;}
 if(roadblockOpponent){roadblockOpponent.gameObject.SetActive(true);if(player)roadblockOpponent.SetTarget(player.transform);}
 if(player&&roadblockFighter)player.SetOpponent(roadblockFighter.transform);
 BeginRoadblockCombat();}
 public void BeginRoadblockCombat(){if(phase!=StreetLegendMissionStage.Roadblock)return;phase=StreetLegendMissionStage.PostRoadblockCombat;if(combatHUD)combatHUD.SetActive(true);}
 public void Finish(){if(phase==StreetLegendMissionStage.PostRoadblockCombat)phase=StreetLegendMissionStage.Complete;}
 public void ResetMission(){triggered=false;phase=StreetLegendMissionStage.HotelCombat;if(vehicle){vehicle.StopVehicle();vehicle.SetDrivingEnabled(false);}if(drivingHUD)drivingHUD.SetActive(false);if(combatHUD)combatHUD.SetActive(true);}
}