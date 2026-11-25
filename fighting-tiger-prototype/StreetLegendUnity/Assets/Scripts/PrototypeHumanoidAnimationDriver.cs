using System.Collections;
using UnityEngine;

/// <summary>
/// Routes gameplay events to the imported Humanoid animation states.
/// Missing clips are safely ignored so capsule fallback fighters still work.
/// </summary>
[RequireComponent(typeof(Animator))]
public class PrototypeHumanoidAnimationDriver : MonoBehaviour
{
    Animator animator;
    Coroutine returnRoutine;
    bool knockedOut;

    void Awake() { animator = GetComponent<Animator>(); }
    void OnEnable() { StreetLegendGameplayEvents.Raised += HandleEvent; }
    void OnDisable()
    {
        StreetLegendGameplayEvents.Raised -= HandleEvent;
        if (returnRoutine != null) StopCoroutine(returnRoutine);
    }

    void HandleEvent(StreetLegendGameEvent gameEvent)
    {
        if (gameEvent.Actor != gameObject || !animator) return;

        switch (gameEvent.Type)
        {
            case StreetLegendEventType.PlayerStartedMoving:
                Play("Guard");
                break;
            case StreetLegendEventType.PlayerStoppedMoving:
                Play("Idle");
                break;
            case StreetLegendEventType.PlayerAttackStarted:
                Play(gameEvent.Heavy ? "HeavyKick" : "Jab");
                ScheduleReturn(0.72f);
                break;
            case StreetLegendEventType.OpponentStartedAttacking:
                Play("Jab");
                ScheduleReturn(0.58f);
                break;
            case StreetLegendEventType.PlayerDamaged:
            case StreetLegendEventType.OpponentDamaged:
                Play("HitReact");
                ScheduleReturn(0.5f);
                break;
            case StreetLegendEventType.PlayerKnockedOut:
            case StreetLegendEventType.OpponentDefeated:
                knockedOut = true;
                if (returnRoutine != null) StopCoroutine(returnRoutine);
                if (!Play("Knockout")) StartCoroutine(FallbackKnockoutPose());
                break;
        }
    }

    bool Play(string stateName)
    {
        if (!animator || !animator.runtimeAnimatorController) return false;
        int hash = Animator.StringToHash(stateName);
        if (!animator.HasState(0, hash)) return false;
        animator.CrossFade(hash, 0.09f, 0);
        return true;
    }

    void ScheduleReturn(float delay)
    {
        if (returnRoutine != null) StopCoroutine(returnRoutine);
        returnRoutine = StartCoroutine(ReturnToGuard(delay));
    }

    IEnumerator ReturnToGuard(float delay)
    {
        yield return new WaitForSeconds(delay);
        returnRoutine = null;
        if (!knockedOut) Play("Guard");
    }

    IEnumerator FallbackKnockoutPose()
    {
        Quaternion start = transform.rotation;
        Quaternion fallen = start * Quaternion.Euler(68f, 0f, 0f);
        float elapsed = 0f;
        while (elapsed < 0.45f)
        {
            elapsed += Time.deltaTime;
            transform.rotation = Quaternion.Slerp(start, fallen, Mathf.Clamp01(elapsed / 0.45f));
            yield return null;
        }
    }
}
