using UnityEngine;
/// <summary>Simple stable arcade vehicle physics controller for mobile prototype driving.</summary>
[RequireComponent(typeof(Rigidbody))]
public class StreetLegendVehicleController : MonoBehaviour {
 public float acceleration=12f, braking=18f, maxSpeed=24f, steerDegrees=72f, lateralGrip=5f;
 Rigidbody body; float throttle, steer; bool brake, enabledDriving=true;
 void Awake(){body=GetComponent<Rigidbody>();body.mass=1300;body.drag=.18f;body.angularDrag=2.2f;body.interpolation=RigidbodyInterpolation.Interpolate;body.collisionDetectionMode=CollisionDetectionMode.ContinuousDynamic;body.centerOfMass=new Vector3(0,-.45f,0);}
 public void SetInput(float steering,float gas,bool brakeInput){steer=Mathf.Clamp(steering,-1,1);throttle=Mathf.Clamp01(gas);brake=brakeInput;}
 public void SetDrivingEnabled(bool value){enabledDriving=value;SetInput(0,0,false);}
 void FixedUpdate(){if(!enabledDriving)return;float speed=Vector3.Dot(body.velocity,transform.forward);if(throttle>0&&speed<maxSpeed)body.AddForce(transform.forward*acceleration*throttle,ForceMode.Acceleration);if(brake)body.AddForce(-transform.forward*braking*Mathf.Clamp(speed/4f,-1,1),ForceMode.Acceleration);float yaw=steer*steerDegrees*Mathf.Clamp01(Mathf.Abs(speed)/4f)*Time.fixedDeltaTime;body.MoveRotation(body.rotation*Quaternion.Euler(0,yaw,0));Vector3 lateral=transform.right*Vector3.Dot(body.velocity,transform.right);body.AddForce(-lateral*lateralGrip,ForceMode.Acceleration);if(body.velocity.magnitude>maxSpeed)body.velocity=body.velocity.normalized*maxSpeed;}
 public void StopVehicle(){SetInput(0,0,true);body.velocity=Vector3.zero;body.angularVelocity=Vector3.zero;}
}
