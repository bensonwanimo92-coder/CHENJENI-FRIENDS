using UnityEngine;

[RequireComponent(typeof(CharacterController))]
public class PrototypeFighterController : MonoBehaviour
{
    [Header("Movement")]
    [SerializeField] float moveSpeed = 4.2f;
    [SerializeField] float gravity = -18f;
    [SerializeField] Transform opponent;
    [Header("Combat")]
    [SerializeField] float attackRange = 1.8f;
    [SerializeField] float lightDamage = 12f;
    [SerializeField] float heavyDamage = 28f;
    [SerializeField] float attackCooldown = 0.55f;
    [SerializeField] float health = 100f;
    CharacterController motor;
    Vector3 verticalVelocity;
    float nextAttack;
    public float Health => health;

    void Awake() { motor = GetComponent<CharacterController>(); }
    void Update()
    {
        float x = Input.GetAxisRaw("Horizontal");
        float z = Input.GetAxisRaw("Vertical");
        Vector3 move = new Vector3(x, 0, z).normalized;
        motor.Move(move * moveSpeed * Time.deltaTime);
        if (move.sqrMagnitude > 0.01f) transform.forward = Vector3.Slerp(transform.forward, move, 14f * Time.deltaTime);
        verticalVelocity.y += gravity * Time.deltaTime;
        motor.Move(verticalVelocity * Time.deltaTime);
        if (opponent) {
            Vector3 face = opponent.position - transform.position; face.y = 0;
            if (face.sqrMagnitude > 0.01f) transform.forward = Vector3.Slerp(transform.forward, face.normalized, 5f * Time.deltaTime);
        }
        if (Input.GetKeyDown(KeyCode.J)) TryAttack(false);
        if (Input.GetKeyDown(KeyCode.K)) TryAttack(true);
    }
    public void TryAttack(bool heavy)
    {
        if (Time.time < nextAttack || !opponent) return;
        nextAttack = Time.time + attackCooldown * (heavy ? 1.5f : 1f);
        if (Vector3.Distance(transform.position, opponent.position) <= attackRange) {
            var target = opponent.GetComponent<PrototypeOpponent>();
            if (target) target.TakeHit(heavy ? heavyDamage : lightDamage, transform.forward, heavy);
        }
    }
    public void SetOpponent(Transform target) { opponent = target; }
}
