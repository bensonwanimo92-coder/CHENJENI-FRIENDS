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
    bool wasMoving;
    public float Health => health;

    void Awake() { motor = GetComponent<CharacterController>(); }

    void Update()
    {
        // Gravity must continue even while stunned or temporarily without a target.
        if (motor.isGrounded && verticalSpeed < 0f) verticalSpeed = -2f;
        verticalSpeed += gravity * Time.deltaTime;

        if (target)
        {
            var playerTarget = target.GetComponent<PrototypeFighterController>();
            if (playerTarget && playerTarget.Health <= 0f) target = null;
        }

        bool movingNow = false;
        if (target && Time.time >= stunUntil && health > 0f)
        {
            Vector3 delta = target.position - transform.position;
            delta.y = 0f;
            if (delta.sqrMagnitude > 0.01f)
                transform.forward = Vector3.Slerp(transform.forward, delta.normalized, 8f * Time.deltaTime);

            if (delta.magnitude > attackRange)
            {
                Vector3 desiredDirection = ChooseApproachDirection(delta.normalized);
                if (desiredDirection.sqrMagnitude > 0.001f)
                {
                    motor.Move(desiredDirection * moveSpeed * Time.deltaTime);
                    movingNow = true;
                }
            }
            else if (Time.time >= nextAttack)
                TryAttack();
        }

        if (movingNow != wasMoving)
        {
            StreetLegendGameplayEvents.Raise(
                movingNow ? StreetLegendEventType.OpponentStartedMoving : StreetLegendEventType.OpponentStoppedMoving,
                gameObject, target ? target.gameObject : null);
            wasMoving = movingNow;
        }
        motor.Move(Vector3.up * verticalSpeed * Time.deltaTime);
    }

    Vector3 ChooseApproachDirection(Vector3 desired)
    {
        Vector3 origin = transform.position + Vector3.up * 0.9f;
        float probeDistance = 0.85f;
        if (!Physics.SphereCast(origin, 0.24f, desired, out RaycastHit hit,
                probeDistance, obstructionMask, QueryTriggerInteraction.Ignore) ||
            hit.collider.transform == target || hit.collider.transform.IsChildOf(target))
            return desired;

        Vector3 left = Quaternion.AngleAxis(-55f, Vector3.up) * desired;
        Vector3 right = Quaternion.AngleAxis(55f, Vector3.up) * desired;
        bool leftBlocked = Physics.SphereCast(origin, 0.24f, left, probeDistance, obstructionMask, QueryTriggerInteraction.Ignore);
        bool rightBlocked = Physics.SphereCast(origin, 0.24f, right, probeDistance, obstructionMask, QueryTriggerInteraction.Ignore);
        if (!leftBlocked && rightBlocked) return left;
        if (!rightBlocked && leftBlocked) return right;
        if (!leftBlocked && !rightBlocked)
            return Vector3.Dot(transform.right, left) > Vector3.Dot(transform.right, right) ? left : right;
        return Vector3.zero;
    }

    void TryAttack()
    {
        nextAttack = Time.time + attackInterval;
        Transform targetAtStart = target;
        StreetLegendGameplayEvents.Raise(StreetLegendEventType.OpponentStartedAttacking, gameObject, targetAtStart ? targetAtStart.gameObject : null);
        StartCoroutine(ResolveAttackAfterWindup(targetAtStart));
    }

    System.Collections.IEnumerator ResolveAttackAfterWindup(Transform targetAtStart)
    {
        yield return new WaitForSeconds(0.2f);
        if (health <= 0f || !targetAtStart || !targetAtStart.gameObject.activeInHierarchy) yield break;

        Collider targetCollider = targetAtStart.GetComponent<Collider>();\n        if (!targetCollider) targetCollider = targetAtStart.GetComponentInChildren<Collider>();
        Vector3 origin = transform.position + Vector3.up * 1.05f;
        Vector3 targetPoint = targetCollider ? targetCollider.ClosestPoint(origin) : targetAtStart.position + Vector3.up;
        Vector3 toTarget = targetPoint - origin;
        float distance = toTarget.magnitude;
        Vector3 flat = toTarget;
        flat.y = 0f;
        if (distance > attackRange || distance < 0.01f ||
            Vector3.Angle(transform.forward, flat.normalized) > attackHalfAngle) yield break;

        if (!HasClearAttackLine(origin, toTarget.normalized, distance + 0.08f, targetAtStart)) yield break;

        var player = targetAtStart.GetComponent<PrototypeFighterController>();
        if (player) player.ReceiveHit(attackDamage, transform.forward, false);
    }

    bool HasClearAttackLine(Vector3 origin, Vector3 direction, float distance, Transform targetTransform)
    {
        RaycastHit[] hits = Physics.RaycastAll(origin, direction, distance, obstructionMask, QueryTriggerInteraction.Ignore);
        System.Array.Sort(hits, (a, b) => a.distance.CompareTo(b.distance));
        foreach (RaycastHit hit in hits)
        {
            Transform hitTransform = hit.collider.transform;
            if (hitTransform == transform || hitTransform.IsChildOf(transform)) continue;
            return hitTransform == targetTransform || hitTransform.IsChildOf(targetTransform);
        }
        return false;
    }

    public void TakeHit(float damage, Vector3 direction, bool heavy)
    {
        if (health <= 0f) return;
        float applied = Mathf.Min(health, Mathf.Max(0f, damage));
        health = Mathf.Max(0f, health - applied);
        StreetLegendGameplayEvents.Raise(StreetLegendEventType.OpponentDamaged, gameObject, null, applied, heavy);
        stunUntil = Time.time + (heavy ? 0.75f : 0.28f);
        if (direction.sqrMagnitude > 0.001f)
            motor.Move(direction.normalized * (heavy ? 0.42f : 0.14f));

        if (health <= 0f)
        {
            StreetLegendGameplayEvents.Raise(StreetLegendEventType.OpponentDefeated, gameObject);
            // Keep the fighter visible so the knockout pose can play and the round manager can show the result.
            motor.enabled = false;
            enabled = false;
        }
    }

    public void ResetVerticalMotion() { verticalSpeed = 0f; stunUntil = Time.time; }
    public void SetTarget(Transform value) { target = value; }
}
