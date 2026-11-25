using UnityEngine;

/// <summary>Attach to an attack collider; enable only during animation active frames.</summary>
public class CombatHitbox : MonoBehaviour
{
    [SerializeField] float damage = 12f;
    [SerializeField] Transform ownerRoot;
    [SerializeField] bool activeHitbox;
    public void Activate() { activeHitbox = true; }
    public void Deactivate() { activeHitbox = false; }
    void OnTriggerEnter(Collider other)
    {
        if (!activeHitbox || (ownerRoot && other.transform.root == ownerRoot)) return;
        var health = other.GetComponentInParent<FighterHealth>();
        if (health && !health.KnockedOut) health.TakeDamage(damage);
    }
}
