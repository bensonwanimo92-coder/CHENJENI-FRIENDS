using UnityEngine;

/// <summary>Basic distance-aware opponent logic; requires an Animator with Attack trigger.</summary>
public class EnemyCombatAI : MonoBehaviour
{
    [SerializeField] Transform player;
    [SerializeField] Animator animator;
    [SerializeField] float attackRange = 1.65f;
    [SerializeField] float moveSpeed = 2.1f;
    [SerializeField] float attackCooldown = 2.2f;
    [SerializeField] float turnRate = 5f;
    float cooldown;
    void Update()
    {
        if (!player) return;
        cooldown -= Time.deltaTime;
        Vector3 delta = player.position - transform.position; delta.y = 0;
        float distance = delta.magnitude;
        if (distance > 0.01f) transform.rotation = Quaternion.Slerp(transform.rotation, Quaternion.LookRotation(delta), turnRate * Time.deltaTime);
        bool close = distance <= attackRange;
        if (animator) animator.SetFloat("MoveSpeed", close ? 0f : 1f);
        if (!close) transform.position += (delta.normalized * moveSpeed * Time.deltaTime);
        else if (cooldown <= 0f) { if (animator) animator.SetTrigger("Attack"); cooldown = attackCooldown; }
    }
    public void SetTarget(Transform target) { player = target; }
}
