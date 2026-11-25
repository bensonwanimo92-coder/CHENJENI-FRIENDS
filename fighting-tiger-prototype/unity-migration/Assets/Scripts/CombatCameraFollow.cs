using UnityEngine;

/// <summary>Soft camera follow for a compact arena. Assign target and tune offset in Inspector.</summary>
public class CombatCameraFollow : MonoBehaviour
{
    [SerializeField] Transform target;
    [SerializeField] Vector3 offset = new Vector3(0f, 4.2f, -7.2f);
    [SerializeField, Min(0.01f)] float followSmooth = 0.18f;
    [SerializeField] bool lookAtTarget = true;
    [SerializeField] Vector3 lookOffset = new Vector3(0f, 1.3f, 0f);
    Vector3 velocity;
    void LateUpdate()
    {
        if (!target) return;
        Vector3 desired = target.position + offset;
        transform.position = Vector3.SmoothDamp(transform.position, desired, ref velocity, followSmooth);
        if (lookAtTarget) transform.LookAt(target.position + lookOffset);
    }
    public void SetTarget(Transform newTarget) { target = newTarget; }
}
