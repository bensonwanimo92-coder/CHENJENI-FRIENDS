using UnityEngine;

/// <summary>Mobile-friendly combat state and animator hooks. Wire attack hitboxes via animation events.</summary>
public class StreetLegendCombat : MonoBehaviour
{
    [Header("References")]
    [SerializeField] Animator animator;
    [SerializeField] CharacterController characterController;
    [Header("Combat")]
    [SerializeField, Min(0)] float stamina = 100f;
    [SerializeField, Min(0)] float staminaCost = 18f;
    [SerializeField] float recoveryPerSecond = 14f;
    [SerializeField] float dodgeDuration = .45f;
    bool busy;
    float dodgeTimer;

    public float Stamina => stamina;
    public bool CanAct => !busy && stamina >= staminaCost;

    void Update()
    {
        stamina = Mathf.Min(100f, stamina + recoveryPerSecond * Time.deltaTime);
        if (dodgeTimer > 0f) dodgeTimer -= Time.deltaTime;
        if (dodgeTimer <= 0f && busy && animator && animator.GetCurrentAnimatorStateInfo(0).IsName("Dodge")) busy = false;
    }

    public void Punch() => Attack("Punch");
    public void Kick() => Attack("Kick");
    public void Special() { if (stamina >= 45f) { stamina -= 45f; Trigger("Special"); } }
    public void Block(bool held) { if (animator) animator.SetBool("Block", held); }

    public void Dodge()
    {
        if (busy || stamina < 20f) return;
        stamina -= 20f; busy = true; dodgeTimer = dodgeDuration;
        Trigger("Dodge");
    }

    void Attack(string trigger)
    {
        if (!CanAct) return;
        stamina -= staminaCost; busy = true; Trigger(trigger);
    }

    void Trigger(string parameter)
    {
        if (animator) animator.SetTrigger(parameter);
    }

    // Call from an animation event at the end of an attack/dodge clip.
    public void AnimationActionComplete() { busy = false; }

    // Call from an animation event during the strike's active frames.
    public void EnableHitbox() { }
    public void DisableHitbox() { }
}
