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
    bool wasMoving;

    public float Health => health;
    public bool IsGrounded => motor && motor.isGrounded;

    void Awake() { motor = GetComponent<CharacterController>(); }

    void Update()
    {
        if (health <= 0f) return;
        if (motor.isGrounded && verticalVelocity.y < 0f) verticalVelocity.y = groundedStickForce;
        verticalVelocity.y += gravity * Time.deltaTime;

        Vector3 move = new Vector3(Input.GetAxisRaw("Horizontal"), 0f, Input.GetAxisRaw("Vertical"));
        move = Vector3.ClampMagnitude(move, 1f);
        bool moving = move.sqrMagnitude > 0.01f && Time.time >= hitStunUntil;
        if (moving)
        {
            motor.Move(move * moveSpeed * Time.deltaTime);
            if (!opponent)
                transform.forward = Vector3.Slerp(transform.forward, move.normalized, 14f * Time.deltaTime);
        }
        if (moving != wasMoving)
        {
            StreetLegendGameplayEvents.Raise(
                moving ? StreetLegendEventType.PlayerStartedMoving : StreetLegendEventType.PlayerStoppedMoving,
                gameObject);
            wasMoving = moving;
        }

        motor.Move(verticalVelocity * Time.deltaTime);
        if (opponent)
        {
            Vector3 face = opponent.position - transform.position;
            face.y = 0f;
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
        StreetLegendGameplayEvents.Raise(StreetLegendEventType.PlayerAttackStarted, gameObject, opponent.gameObject, 0f, heavy);

        Collider targetCollider = opponent.GetComponent<Collider>();
        Vector3 origin = transform.position + Vector3.up * 1.05f;
        Vector3 targetPoint = targetCollider ? targetCollider.ClosestPoint(origin) : opponent.position + Vector3.up;
        Vector3 toTarget = targetPoint - origin;
        float distance = toTarget.magnitude;
        if (distance > attackRange || distance < 0.01f)
        {
            StreetLegendGameplayEvents.Raise(StreetLegendEventType.PlayerAttackMissed, gameObject, opponent.gameObject, 0f, heavy);
            return;
        }

        Vector3 flatDirection = toTarget;
        flatDirection.y = 0f;
        if (flatDirection.sqrMagnitude > 0.001f &&
            Vector3.Angle(transform.forward, flatDirection.normalized) > attackHalfAngle)
        {
            StreetLegendGameplayEvents.Raise(StreetLegendEventType.PlayerAttackMissed, gameObject, opponent.gameObject, 0f, heavy);
            return;
        }

        if (Physics.Raycast(origin, toTarget.normalized, out RaycastHit hit, distance + 0.08f, obstructionMask, QueryTriggerInteraction.Ignore))
        {
            if (hit.collider.transform != opponent && !hit.collider.transform.IsChildOf(opponent))
            {
                StreetLegendGameplayEvents.Raise(StreetLegendEventType.PlayerAttackMissed, gameObject, opponent.gameObject, 0f, heavy);
                return;
            }
        }

        var target = opponent.GetComponent<PrototypeOpponent>();
        if (target)
        {
            float before = target.Health;
            target.TakeHit(heavy ? heavyDamage : lightDamage, transform.forward, heavy);
            float applied = Mathf.Max(0f, before - target.Health);
            if (applied > 0f)
                StreetLegendGameplayEvents.Raise(StreetLegendEventType.PlayerHitConfirmed, gameObject, opponent.gameObject, applied, heavy);
            else
                StreetLegendGameplayEvents.Raise(StreetLegendEventType.PlayerAttackMissed, gameObject, opponent.gameObject, 0f, heavy);
        }
    }

    public void ReceiveHit(float damage, Vector3 direction, bool heavy)
    {
        if (health <= 0f) return;
        float applied = Mathf.Min(health, Mathf.Max(0f, damage));
        health = Mathf.Max(0f, health - applied);
        hitStunUntil = Time.time + (heavy ? 0.65f : 0.25f);
        StreetLegendGameplayEvents.Raise(StreetLegendEventType.PlayerDamaged, gameObject, null, applied, heavy);

        if (direction.sqrMagnitude > 0.001f)
            motor.Move(direction.normalized * (heavy ? 0.22f : 0.08f));

        if (health <= 0f)
        {
            StreetLegendGameplayEvents.Raise(StreetLegendEventType.PlayerKnockedOut, gameObject);
            Debug.Log("Player defeated. Trigger defeat/retry flow.");
        }
    }

    public void ResetVerticalMotion() { verticalVelocity = Vector3.zero; hitStunUntil = Time.time; }
    public void SetOpponent(Transform target) { opponent = target; }
}
