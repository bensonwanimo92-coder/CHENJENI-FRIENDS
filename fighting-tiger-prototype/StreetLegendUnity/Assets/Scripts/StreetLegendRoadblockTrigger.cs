using UnityEngine;
public class StreetLegendRoadblockTrigger:MonoBehaviour{
 public StreetLegendMissionPhase mission;void Awake(){if(!mission)mission=FindObjectOfType<StreetLegendMissionPhase>();}
 void OnTriggerEnter(Collider other){if(other.CompareTag("PlayerVehicle")&&mission)mission.RoadblockReached();}
}
