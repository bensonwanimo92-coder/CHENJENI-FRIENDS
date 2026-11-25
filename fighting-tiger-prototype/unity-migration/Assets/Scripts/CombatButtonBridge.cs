using UnityEngine;

/// <summary>Connect Unity UI Button press/release events to fighter combat actions.</summary>
public class CombatButtonBridge : MonoBehaviour
{
    [SerializeField] StreetLegendCombat fighter;
    public void Punch() { if (fighter) fighter.Punch(); }
    public void Kick() { if (fighter) fighter.Kick(); }
    public void Dodge() { if (fighter) fighter.Dodge(); }
    public void Special() { if (fighter) fighter.Special(); }
    public void BlockDown() { if (fighter) fighter.Block(true); }
    public void BlockUp() { if (fighter) fighter.Block(false); }
}
