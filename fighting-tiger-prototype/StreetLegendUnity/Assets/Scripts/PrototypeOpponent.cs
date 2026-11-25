using UnityEngine;

[RequireComponent(typeof(CharacterController))]
public class PrototypeOpponent : MonoBehaviour
{
    [SerializeField] Transform target;
    [SerializeField] float health = 100f;
    [SerializeField] float moveSpeed = 2.5f;
    [SerializeField] float gravity = -20f;
    [SerializeField] float attackRange = 1.55f;
    [SerializeField] float attackHalfAngle = 60f;
    [SerializeField] float attackDamage = 8f;
    [SerializeField] float attackInterval = 1.35f;
    [SerializeField] LayerMask obstructionMask = ~0;
    CharacterController motor;
    float nextAttack;
    float stunUntil;
    float verticalSpeed;
    public float Health => health;

    void Awake() { motor = GetComponent<CharacterController>(); }
    void Update()
    {
        if (!target || Time.time < stunUntil || health <= 0f) return;
        if (motor.isGrounded && verticalSpeed < 0f) verticalSpeed = -2f;
        verticalSpeed += gravity * Time.deltaTime;
        Vector3 delta = target.position - transform.position; delta.y = 0f;
        if (delta.sqrMagnitude > 0.01f)
            transform.forward = Vector3.Slerp(transform.forward, delta.normalized, 8f * Time.deltaTime);
        if (delta.magnitude > attackRange)
            motor.Move(delta.normalized * moveSpeed * Time.deltaTime);
        else if (Time.time >= nextAttack)
            TryAttack();
        motor.Move(Vector3.up * verticalSpeed * Time.deltaTime);
    }

    void TryAttack()
    {
        nextAttack = Time.time + attackInterval;
        Collider targetCollider = target.GetComponent<Collider>();
        Vector3 origin = transform.position + Vector3.up * 1.05f;
        Vector3 targetPoint = targetCollider ? targetCollider.ClosestPoint(origin) : target.position + Vector3.up;
        Vector3 toTarget = targetPoint - origin;
        float distance = toTarget.magnitude;
        Vector3 flat = toTarget; flat.y = 0f;
        if (distance > attackRange || distance < 0.01f ||
            Vector3.Angle(transform.forward, flat.normalized) > attackHalfAngle) return;
        if (Physics.Raycast(origin, toTarget.normalized, out RaycastHit hit, distance + 0.08f, obstructionMask, QueryTriggerInteraction.Ignore))
            if (hit.collider.transform != target && !hit.collider.transform.IsChildOf(target)) return;
        var player = target.GetComponent<PrototypeFighterController>();
        if (player) player.ReceiveHit(attackDamage, transform.forward, false);
    }

    public void TakeHit(float damage, Vector3 direction, bool heavy)
    {
        if (health <= 0f) return;
        health = Mathf.Max(0f, health - Mathf.Max(0f, damage));
        stunUntil = Time.time + (heavy ? 0.75f : 0.28f);
        if (direction.sqrMagnitude > 0.001f)
            motor.Move(direction.normalized * (heavy ? 0.42f : 0.14f));
        if (health <= 0f) gameObject.SetActive(false);
    }
    public void ResetVerticalMotion() { verticalSpeed = 0f; stunUntil = Time.time; }
    public void SetTarget(Transform value) { target = value; }
}
