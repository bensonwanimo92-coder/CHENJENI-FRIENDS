using UnityEngine;
public enum StreetLegendMissionPhase{HotelCombat,DrivingPursuit,Roadblock,PostRoadblockCombat,Complete}
/// <summary>Single-authority phase gate for future seamless mission transitions.</summary>
public class StreetLegendMissionPhase:MonoBehaviour{
 public StreetLegendMissionPhase phase=StreetLegendMissionPhase.HotelCombat;
 public StreetLegendVehicleController vehicle; public GameObject drivingHUD,combatHUD; bool triggered;
 public void BeginPursuit(){if(phase!=StreetLegendMissionPhase.HotelCombat)return;phase=StreetLegendMissionPhase.DrivingPursuit;if(vehicle)vehicle.SetDrivingEnabled(true);if(drivingHUD)drivingHUD.SetActive(true);if(combatHUD)combatHUD.SetActive(false);}
 public void RoadblockReached(){if(phase!=StreetLegendMissionPhase.DrivingPursuit||triggered)return;triggered=true;phase=StreetLegendMissionPhase.Roadblock;if(vehicle){vehicle.StopVehicle();vehicle.SetDrivingEnabled(false);}if(drivingHUD)drivingHUD.SetActive(false);}
 public void BeginRoadblockCombat(){if(phase!=StreetLegendMissionPhase.Roadblock)return;phase=StreetLegendMissionPhase.PostRoadblockCombat;if(combatHUD)combatHUD.SetActive(true);}
 public void Finish(){if(phase==StreetLegendMissionPhase.PostRoadblockCombat)phase=StreetLegendMissionPhase.Complete;}
 public void ResetMission(){triggered=false;phase=StreetLegendMissionPhase.HotelCombat;if(vehicle)vehicle.SetDrivingEnabled(false);if(drivingHUD)drivingHUD.SetActive(false);if(combatHUD)combatHUD.SetActive(true);}
}
