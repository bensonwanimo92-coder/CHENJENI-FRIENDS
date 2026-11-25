using UnityEngine;

public class PrototypeCameraFollow : MonoBehaviour
{
    public Transform target;
    [SerializeField] Vector3 offset = new Vector3(0f, 7f, -9f);
    void LateUpdate()
    {
        if (!target) return;
        transform.position = Vector3.Lerp(transform.position, target.position + offset, 5f * Time.deltaTime);
        transform.LookAt(target.position + Vector3.up * 1.1f);
    }
}
