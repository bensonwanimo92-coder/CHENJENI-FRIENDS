using UnityEngine;
public class StreetLegendRoadblockTrigger:MonoBehaviour{
 public StreetLegendMissionPhase mission;void Awake(){if(!mission)mission=FindObjectOfType<StreetLegendMissionPhase>();}
 void OnTriggerEnter(Collider other){var car=other.GetComponentInParent<StreetLegendVehicleController>();if(car&&mission&&car==mission.vehicle)mission.RoadblockReached();}
}
