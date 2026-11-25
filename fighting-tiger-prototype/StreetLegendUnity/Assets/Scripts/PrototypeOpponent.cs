using UnityEngine;

[RequireComponent(typeof(CharacterController))]
public class PrototypeOpponent : MonoBehaviour
{
    [SerializeField] Transform target;
    [SerializeField] float health = 100f;
    [SerializeField] float moveSpeed = 2.5f;
    [SerializeField] float attackRange = 1.65f;
    [SerializeField] float attackDamage = 8f;
    [SerializeField] float attackInterval = 1.35f;
    CharacterController motor;
    float nextAttack;
    float stunUntil;
    void Awake() { motor = GetComponent<CharacterController>(); }
    void Update()
    {
        if (!target || Time.time < stunUntil || health <= 0) return;
        Vector3 delta = target.position - transform.position; delta.y = 0;
        if (delta.sqrMagnitude > 0.01f) transform.forward = Vector3.Slerp(transform.forward, delta.normalized, 8f * Time.deltaTime);
        if (delta.magnitude > attackRange) motor.Move(delta.normalized * moveSpeed * Time.deltaTime);
        else if (Time.time >= nextAttack) {
            nextAttack = Time.time + attackInterval;
            var player = target.GetComponent<PrototypeFighterController>();
            if (player) Debug.Log("Opponent attacks. Player health system will be connected in the next combat pass.");
        }
    }
    public void TakeHit(float damage, Vector3 direction, bool heavy)
    {
        health -= damage;
        stunUntil = Time.time + (heavy ? 0.75f : 0.28f);
        transform.position += direction.normalized * (heavy ? 0.48f : 0.16f);
        if (health <= 0) { health = 0; gameObject.SetActive(false); }
    }
    public void SetTarget(Transform value) { target = value; }
}
