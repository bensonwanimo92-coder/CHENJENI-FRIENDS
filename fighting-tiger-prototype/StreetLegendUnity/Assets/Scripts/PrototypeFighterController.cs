using UnityEngine;

[RequireComponent(typeof(CharacterController))]
public class PrototypeFighterController : MonoBehaviour
{
    [Header("Movement / physics")]
    [SerializeField] float moveSpeed = 4.2f;
    [SerializeField] float gravity = -20f;
    [SerializeField] float groundedStickForce = -2f;
    [SerializeField] float health = 100f;
    [SerializeField] Transform opponent;
    [Header("Combat validation")]
    [SerializeField] float attackRange = 1.65f;
    [SerializeField, Range(0f, 90f)] float attackHalfAngle = 55f;
    [SerializeField] float lightDamage = 12f;
    [SerializeField] float heavyDamage = 28f;
    [SerializeField] float attackCooldown = 0.55f;
    [SerializeField] LayerMask obstructionMask = ~0;
    CharacterController motor;
    Vector3 verticalVelocity;
    float nextAttack;
    float hitStunUntil;
    public float Health => health;
    public bool IsGrounded => motor && motor.isGrounded;

    void Awake() { motor = GetComponent<CharacterController>(); }
    void Update()
    {
        if (health <= 0f) return;
        if (motor.isGrounded && verticalVelocity.y < 0f) verticalVelocity.y = groundedStickForce;
        verticalVelocity.y += gravity * Time.deltaTime;
        Vector3 move = new Vector3(Input.GetAxisRaw("Horizontal"), 0f, Input.GetAxisRaw("Vertical")).normalized;
        if (Time.time >= hitStunUntil)
        {
            motor.Move(move * moveSpeed * Time.deltaTime);
            if (move.sqrMagnitude > 0.01f && !opponent)
                transform.forward = Vector3.Slerp(transform.forward, move, 14f * Time.deltaTime);
        }
        motor.Move(verticalVelocity * Time.deltaTime);
        if (opponent)
        {
            Vector3 face = opponent.position - transform.position; face.y = 0f;
            if (face.sqrMagnitude > 0.01f)
                transform.forward = Vector3.Slerp(transform.forward, face.normalized, 8f * Time.deltaTime);
        }
        if (Input.GetKeyDown(KeyCode.J)) TryAttack(false);
        if (Input.GetKeyDown(KeyCode.K)) TryAttack(true);
    }

    public void TryAttack(bool heavy)
    {
        if (Time.time < nextAttack || !opponent || health <= 0f) return;
        nextAttack = Time.time + attackCooldown * (heavy ? 1.5f : 1f);
        Collider targetCollider = opponent.GetComponent<Collider>();
        Vector3 origin = transform.position + Vector3.up * 1.05f;
        Vector3 targetPoint = targetCollider ? targetCollider.ClosestPoint(origin) : opponent.position + Vector3.up;
        Vector3 toTarget = targetPoint - origin;
        float distance = toTarget.magnitude;
        if (distance > attackRange || distance < 0.01f) return;
        Vector3 flatDirection = toTarget; flatDirection.y = 0f;
        if (flatDirection.sqrMagnitude > 0.001f &&
            Vector3.Angle(transform.forward, flatDirection.normalized) > attackHalfAngle) return;
        if (Physics.Raycast(origin, toTarget.normalized, out RaycastHit hit, distance + 0.08f, obstructionMask, QueryTriggerInteraction.Ignore))
        {
            if (hit.collider.transform != opponent && !hit.collider.transform.IsChildOf(opponent)) return;
        }
        var target = opponent.GetComponent<PrototypeOpponent>();
        if (target) target.TakeHit(heavy ? heavyDamage : lightDamage, transform.forward, heavy);
    }

    public void ReceiveHit(float damage, Vector3 direction, bool heavy)
    {
        if (health <= 0f) return;
        health = Mathf.Max(0f, health - Mathf.Max(0f, damage));
        hitStunUntil = Time.time + (heavy ? 0.65f : 0.25f);
        if (direction.sqrMagnitude > 0.001f)
            motor.Move(direction.normalized * (heavy ? 0.22f : 0.08f));
        if (health <= 0f) Debug.Log("Player defeated. Trigger defeat/retry flow.");
    }

    public void ResetVerticalMotion() { verticalVelocity = Vector3.zero; hitStunUntil = Time.time; }\n    public void SetOpponent(Transform target) { opponent = target; }
}
