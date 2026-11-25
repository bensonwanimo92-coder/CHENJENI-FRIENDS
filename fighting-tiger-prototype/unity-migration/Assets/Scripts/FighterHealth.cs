using UnityEngine;
using UnityEngine.Events;

public class FighterHealth : MonoBehaviour
{
    [SerializeField, Min(1)] float maxHealth = 100f;
    [SerializeField] float health;
    [SerializeField] UnityEvent onKnockout;
    public float Current => health;
    public float Max => maxHealth;
    public bool KnockedOut => health <= 0f;

    void Awake() { health = maxHealth; }

    public void TakeDamage(float amount)
    {
        if (KnockedOut || amount <= 0f) return;
        health = Mathf.Max(0f, health - amount);
        if (health <= 0f) onKnockout?.Invoke();
    }

    public void ResetHealth() { health = maxHealth; }
}
