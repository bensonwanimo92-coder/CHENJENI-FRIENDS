using UnityEngine;

/// <summary>
/// Safety net for prototype levels. Place this on a CharacterController root.
/// Configure a checkpoint and a kill-plane height for each level.
/// </summary>
[RequireComponent(typeof(CharacterController))]
public class PrototypeFallRecovery : MonoBehaviour
{
    [SerializeField] Transform checkpoint;
    [SerializeField] float fallThreshold = -8f;
    [SerializeField] float recoveryCooldown = 1f;
    [SerializeField] bool disableObjectIfNoCheckpoint;
    CharacterController controller;
    Vector3 fallbackPosition;
    Quaternion fallbackRotation;
    float nextRecoveryTime;

    void Awake()
    {
        controller = GetComponent<CharacterController>();
        fallbackPosition = transform.position;
        fallbackRotation = transform.rotation;
    }

    void LateUpdate()
    {
        if (transform.position.y >= fallThreshold || Time.time < nextRecoveryTime) return;
        nextRecoveryTime = Time.time + recoveryCooldown;

        if (!checkpoint && disableObjectIfNoCheckpoint)
        {
            gameObject.SetActive(false);
            return;
        }

        Vector3 destination = checkpoint ? checkpoint.position : fallbackPosition;
        Quaternion rotation = checkpoint ? checkpoint.rotation : fallbackRotation;
        controller.enabled = false;
        transform.SetPositionAndRotation(destination, rotation);
        controller.enabled = true;

        var player = GetComponent<PrototypeFighterController>();
        if (player) player.ResetVerticalMotion();
        var opponent = GetComponent<PrototypeOpponent>();
        if (opponent) opponent.ResetVerticalMotion();
        Debug.Log(name + " recovered from falling below the level.");
    }

    public void SetCheckpoint(Transform value) { checkpoint = value; }
}
