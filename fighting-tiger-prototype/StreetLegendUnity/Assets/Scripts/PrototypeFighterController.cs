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
    bool wasInCombatRange;
    Vector2 mobileMoveInput;

    public float Health => health;
    public PrototypeOpponent Opponent => opponent ? opponent.GetComponent<PrototypeOpponent>() : null;
    public bool IsGrounded => motor && motor.isGrounded;

    void Awake() { motor = GetComponent<CharacterController>(); }

    void Update()
    {
        if (motor.isGrounded && verticalVelocity.y < 0f) verticalVelocity.y = groundedStickForce;
        verticalVelocity.y += gravity * Time.deltaTime;

        // A knocked-out fighter must still obey gravity and remain grounded.
        if (health <= 0f)
        {
            motor.Move(verticalVelocity * Time.deltaTime);
            if (wasMoving)
                StreetLegendGameplayEvents.Raise(StreetLegendEventType.PlayerStoppedMoving, gameObject);
            wasMoving = false;
            return;
        }

        Vector2 keyboardMove = new Vector2(Input.GetAxisRaw("Horizontal"), Input.GetAxisRaw("Vertical"));
        Vector2 combinedMove = keyboardMove.sqrMagnitude > 0.01f ? keyboardMove : mobileMoveInput;
        Vector3 move = Vector3.ClampMagnitude(new Vector3(combinedMove.x, 0f, combinedMove.y), 1f);
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

            if (!opponent.gameObject.activeInHierarchy)
            {
                wasInCombatRange = false;
            }
            else
            {
                bool inRange = face.magnitude <= attackRange + 0.2f;
                if (inRange != wasInCombatRange)
                {
                    StreetLegendGameplayEvents.Raise(
                        inRange ? StreetLegendEventType.PlayerEnteredCombatRange : StreetLegendEventType.PlayerLeftCombatRange,
                        gameObject, opponent.gameObject);
                    wasInCombatRange = inRange;
                }
            }
        }

        if (Input.GetKeyDown(KeyCode.J)) TryAttack(false);
        if (Input.GetKeyDown(KeyCode.K)) TryAttack(true);
    }

    public void TryAttack(bool heavy)
    {
        if (Time.time < nextAttack || !opponent || health <= 0f || Time.time < hitStunUntil) return;
        nextAttack = Time.time + attackCooldown * (heavy ? 1.5f : 1f);
        StreetLegendGameplayEvents.Raise(StreetLegendEventType.PlayerAttackStarted, gameObject, opponent.gameObject, 0f, heavy);
        StartCoroutine(ResolveAttackAfterWindup(heavy, opponent));
    }

    System.Collections.IEnumerator ResolveAttackAfterWindup(bool heavy, Transform targetAtStart)
    {
        // Gives animation controllers a real anticipation window before impact.
        yield return new WaitForSeconds(heavy ? 0.28f : 0.16f);
        if (health <= 0f || Time.time < hitStunUntil || !targetAtStart || !targetAtStart.gameObject.activeInHierarchy)
            yield break;

        Collider targetCollider = targetAtStart.GetComponent<Collider>(); 
        if (!targetCollider) targetCollider = targetAtStart.GetComponentInChildren<Collider>();
        Vector3 origin = transform.position + Vector3.up * 1.05f;
        Vector3 targetPoint = targetCollider ? targetCollider.ClosestPoint(origin) : targetAtStart.position + Vector3.up;
        Vector3 toTarget = targetPoint - origin;
        float distance = toTarget.magnitude;
        if (distance > attackRange || distance < 0.01f)
        {
            RaiseAttackMiss(targetAtStart, heavy);
            yield break;
        }

        Vector3 flatDirection = toTarget;
        flatDirection.y = 0f;
        if (flatDirection.sqrMagnitude > 0.001f &&
            Vector3.Angle(transform.forward, flatDirection.normalized) > attackHalfAngle)
        {
            RaiseAttackMiss(targetAtStart, heavy);
            yield break;
        }

        if (!HasClearAttackLine(origin, toTarget.normalized, distance + 0.08f, targetAtStart))
        {
            RaiseAttackMiss(targetAtStart, heavy);
            yield break;
        }

        var target = targetAtStart.GetComponent<PrototypeOpponent>();
        if (!target)
        {
            RaiseAttackMiss(targetAtStart, heavy);
            yield break;
        }

        float before = target.Health;
        target.TakeHit(heavy ? heavyDamage : lightDamage, transform.forward, heavy);
        float applied = Mathf.Max(0f, before - target.Health);
        if (applied > 0f)
            StreetLegendGameplayEvents.Raise(StreetLegendEventType.PlayerHitConfirmed, gameObject, targetAtStart.gameObject, applied, heavy);
        else
            RaiseAttackMiss(targetAtStart, heavy);
    }

    bool HasClearAttackLine(Vector3 origin, Vector3 direction, float distance, Transform target)
    {
        // RaycastAll lets us ignore the attacker's own colliders and evaluate the
        // nearest real obstruction instead of accidentally blocking on our body.
        RaycastHit[] hits = Physics.RaycastAll(origin, direction, distance, obstructionMask, QueryTriggerInteraction.Ignore);
        System.Array.Sort(hits, (a, b) => a.distance.CompareTo(b.distance));
        foreach (RaycastHit hit in hits)
        {
            Transform hitTransform = hit.collider.transform;
            if (hitTransform == transform || hitTransform.IsChildOf(transform)) continue;
            return hitTransform == target || hitTransform.IsChildOf(target);
        }
        return false;
    }

    void RaiseAttackMiss(Transform target, bool heavy)
    {
        StreetLegendGameplayEvents.Raise(StreetLegendEventType.PlayerAttackMissed, gameObject,
            target ? target.gameObject : null, 0f, heavy);
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

    public void SetMobileMoveInput(Vector2 value) { mobileMoveInput = Vector2.ClampMagnitude(value, 1f); }
    public void ResetVerticalMotion() { verticalVelocity = Vector3.zero; hitStunUntil = Time.time; }
    public void SetOpponent(Transform target) { opponent = target; }
}
