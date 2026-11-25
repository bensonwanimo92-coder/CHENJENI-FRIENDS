using System.Collections;
using UnityEngine;

/// <summary>Connects hotel encounter completion to the prototype pursuit without coupling combat scripts.</summary>
public class StreetLegendMissionIntegrationDirector : MonoBehaviour
{
 public PrototypeOpponent hotelOpponent;
 public StreetLegendMissionPhase mission;
 public StreetLegendVehicleController vehicle;
 public StreetLegendDrivingHUD drivingHud;
 public Transform vehicleEntryPoint;
 public PrototypeFighterController hotelPlayer;
 bool sequenceStarted;
 void Update()
 {
  if(sequenceStarted||!hotelOpponent||!mission||!vehicle)return;
  if(hotelOpponent.Health<=0f)StartCoroutine(LaunchPursuit());
 }
 IEnumerator LaunchPursuit()
 {
  sequenceStarted=true;
  if(hotelPlayer)hotelPlayer.enabled=false;
  if(vehicleEntryPoint)vehicle.transform.position=vehicleEntryPoint.position;
  vehicle.transform.rotation=vehicleEntryPoint?vehicleEntryPoint.rotation:Quaternion.identity;
  vehicle.gameObject.SetActive(true);
  yield return new WaitForSecondsRealtime(1.8f);
  mission.BeginPursuit();
  if(drivingHud)drivingHud.enabled=true;
 }
}
