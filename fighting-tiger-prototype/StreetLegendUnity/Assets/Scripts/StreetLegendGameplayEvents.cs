using System;
using UnityEngine;

public enum StreetLegendEventType
{
    PlayerStartedMoving,
    PlayerStoppedMoving,
    OpponentStartedMoving,
    OpponentStoppedMoving,
    PlayerAttackStarted,
    PlayerAttackMissed,
    PlayerHitConfirmed,
    PlayerDamaged,
    PlayerKnockedOut,
    OpponentStartedAttacking,
    OpponentDamaged,
    OpponentGuarded,
    PlayerEnteredCombatRange,
    PlayerLeftCombatRange,
    OpponentDefeated
}

public struct StreetLegendGameEvent
{
    public StreetLegendEventType Type;
    public GameObject Actor;
    public GameObject Target;
    public float Amount;
    public bool Heavy;

    public StreetLegendGameEvent(StreetLegendEventType type, GameObject actor, GameObject target, float amount, bool heavy)
    {
        Type = type;
        Actor = actor;
        Target = target;
        Amount = amount;
        Heavy = heavy;
    }
}

/// <summary>
/// Event bridge for voice-only commentary, UI and future gameplay systems.
/// Subscribers must validate context and must not assume every event needs speech.
/// </summary>
public static class StreetLegendGameplayEvents
{
    public static event Action<StreetLegendGameEvent> Raised;

    public static void Raise(StreetLegendEventType type, GameObject actor, GameObject target = null, float amount = 0f, bool heavy = false)
    {
        Raised?.Invoke(new StreetLegendGameEvent(type, actor, target, amount, heavy));
    }
}
