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
 public PrototypeMatchManager hotelMatchManager;
 bool sequenceStarted;
 void Update()
 {
  if(sequenceStarted||!hotelOpponent||!mission||!vehicle)return;
  if(hotelOpponent.Health<=0f)StartCoroutine(LaunchPursuit());
 }
 IEnumerator LaunchPursuit()
 {
  sequenceStarted=true;
  // The prototype round manager's isolated victory overlay would freeze the time scale.
  // Disable it for the campaign transition and explicitly restore time scale.
  if(hotelMatchManager)hotelMatchManager.gameObject.SetActive(false);
  Time.timeScale=1f;
  if(hotelPlayer)hotelPlayer.enabled=false;
  if(vehicleEntryPoint){vehicle.transform.position=vehicleEntryPoint.position;vehicle.transform.rotation=vehicleEntryPoint.rotation;}
  vehicle.gameObject.SetActive(true);
  yield return new WaitForSecondsRealtime(1.6f);
  Time.timeScale=1f;
  mission.BeginPursuit();
  if(drivingHud)drivingHud.enabled=true;
 }
}
