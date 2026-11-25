using UnityEngine;

/// <summary>
/// Companion tactical layer: enemy reacts to player attack proximity, avoids
/// blindly rushing, pauses during recovery, and occasionally guards.
/// Integrate these state outputs with the enemy Animator and attack system.
/// </summary>
public class EnemyCombatTactics : MonoBehaviour
{
    public enum State { Approach, Guard, Recover, AttackOpportunity }
    [SerializeField] Transform player;
    [SerializeField] Animator animator;
    [SerializeField] float guardChance = 0.22f;
    [SerializeField] float guardDuration = 0.7f;
    [SerializeField] float recoveryDuration = 0.45f;
    [SerializeField] float attackThreatRange = 2.2f;
    [SerializeField] string guardBool = "Guard";
    [SerializeField] string recoveryBool = "Recover";

    State state = State.Approach;
    float stateTimer;
    public State CurrentState => state;

    void Update()
    {
        stateTimer -= Time.deltaTime;
        if (!player) return;

        float distance = Vector3.Distance(transform.position, player.position);
        bool playerThreatening = distance < attackThreatRange;

        if (stateTimer <= 0f)
        {
            if (playerThreatening && Random.value < guardChance)
            {
                state = State.Guard; stateTimer = guardDuration;
            }
            else
            {
                state = State.Approach; stateTimer = Random.Range(0.5f, 1.15f);
            }
        }

        if (animator)
        {
            animator.SetBool(guardBool, state == State.Guard);
            animator.SetBool(recoveryBool, state == State.Recover);
        }
    }

    public void NotifyAttackFinished()
    {
        state = State.Recover;
        stateTimer = recoveryDuration;
    }

    public void SetTarget(Transform target) => player = target;
}
