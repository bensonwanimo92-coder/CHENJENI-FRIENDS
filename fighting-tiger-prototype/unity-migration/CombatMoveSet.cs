using UnityEngine;

/// <summary>Hard-fight moveset bridge. Animator triggers and damage values are
/// configurable; connect animation events to Open/CloseHitWindow.</summary>
public class CombatMoveSet : MonoBehaviour
{
    [System.Serializable] public class Move
    {
        public string name = "Move";
        public string animatorTrigger = "Punch";
        public float damage = 12f;
        public float staminaCost = 10f;
        public float cooldown = 0.5f;
        public bool heavy;
    }
    [SerializeField] Animator animator;
    [SerializeField] Move[] moves;
    [SerializeField] float stamina = 100f;
    [SerializeField] float staminaRegen = 12f;
    [SerializeField] float moveCooldown;
    public float Stamina => stamina;

    void Update()
    {
        stamina = Mathf.Min(100f, stamina + staminaRegen * Time.deltaTime);
        moveCooldown = Mathf.Max(0f, moveCooldown - Time.deltaTime);
    }

    public bool ExecuteMove(int index)
    {
        if (moves == null || index < 0 || index >= moves.Length || moveCooldown > 0f) return false;
        Move m = moves[index];
        if (stamina < m.staminaCost) return false;
        stamina -= m.staminaCost;
        moveCooldown = m.cooldown;
        if (animator && !string.IsNullOrEmpty(m.animatorTrigger)) animator.SetTrigger(m.animatorTrigger);
        return true;
    }
}
