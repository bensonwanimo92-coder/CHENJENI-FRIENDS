using UnityEngine;

public class PrototypeCameraFollow : MonoBehaviour
{
    public Transform target;
    [SerializeField] Vector3 offset = new Vector3(0f, 7f, -9f);
    [SerializeField] float followSharpness = 5f;
    [SerializeField] float lookHeight = 1.1f;
    [SerializeField] float collisionRadius = 0.25f;
    [SerializeField] float wallPadding = 0.18f;
    [SerializeField] LayerMask collisionMask = ~0;

    void LateUpdate()
    {
        if (!target) return;

        Vector3 focus = target.position + Vector3.up * lookHeight;
        Vector3 desired = target.position + offset;
        Vector3 toCamera = desired - focus;
        float distance = toCamera.magnitude;
        if (distance > 0.001f && Physics.SphereCast(
            focus, collisionRadius, toCamera.normalized, out RaycastHit hit,
            distance, collisionMask, QueryTriggerInteraction.Ignore))
        {
            // Keep the camera in front of walls instead of letting it clip through geometry.
            desired = focus + toCamera.normalized * Mathf.Max(0.35f, hit.distance - wallPadding);
        }

        transform.position = Vector3.Lerp(transform.position, desired, 1f - Mathf.Exp(-followSharpness * Time.deltaTime));
        transform.LookAt(focus);
    }
}
