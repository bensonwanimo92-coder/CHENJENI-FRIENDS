using UnityEngine;

/// <summary>
/// Receives combat hit events and drives believable stagger reactions.
/// Animation trigger names are configurable to match the Animator Controller.
/// </summary>
public class HitReactionController : MonoBehaviour
{
    [Header("Animator")]
    [SerializeField] Animator animator;
    [SerializeField] string lightHitTrigger = "HitLight";
    [SerializeField] string heavyHitTrigger = "HitHeavy";
    [SerializeField] string knockdownTrigger = "Knockdown";

    [Header("Impulse (optional Rigidbody)")]
    [SerializeField] Rigidbody body;
    [SerializeField] float lightPush = 1.2f;
    [SerializeField] float heavyPush = 3.2f;
    [SerializeField] float knockdownPush = 5f;
    [SerializeField] float upwardLift = 0.35f;

    public void ReactToHit(float damage, Vector3 hitDirection)
    {
        if (hitDirection.sqrMagnitude < 0.001f) hitDirection = transform.forward;
        hitDirection.y = 0f;
        hitDirection.Normalize();

        if (animator)
        {
            if (damage >= 35f) animator.SetTrigger(knockdownTrigger);
            else if (damage >= 18f) animator.SetTrigger(heavyHitTrigger);
            else animator.SetTrigger(lightHitTrigger);
        }

        if (body && !body.isKinematic)
        {
            float force = damage >= 35f ? knockdownPush : damage >= 18f ? heavyPush : lightPush;
            body.AddForce(hitDirection * force + Vector3.up * upwardLift, ForceMode.Impulse);
        }
    }
}
