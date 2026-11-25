using UnityEngine;
/// <summary>Waypoint-paced escape vehicle that remains ahead without teleporting.</summary>
[RequireComponent(typeof(Rigidbody))]
public class StreetLegendChaseTarget : MonoBehaviour {
 public Transform[] route; public float speed=14f, waypointRadius=5f; int index; Rigidbody body;
 void Awake(){body=GetComponent<Rigidbody>();body.isKinematic=true;}
 void FixedUpdate(){if(route==null||route.Length==0)return;Transform target=route[index];Vector3 flat=target.position-transform.position;flat.y=0;if(flat.magnitude<waypointRadius)index=(index+1)%route.Length;else{Quaternion facing=Quaternion.LookRotation(flat.normalized);transform.rotation=Quaternion.RotateTowards(transform.rotation,facing,100*Time.fixedDeltaTime);transform.position+=transform.forward*speed*Time.fixedDeltaTime;}}
}
