using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class CommentatorLineSet
{
    public StreetLegendEventType eventType;
    [TextArea] public string editorNotes;
    public AudioClip[] voiceVariations;
    [Min(0f)] public float cooldownSeconds = 2f;
    [Range(0, 10)] public int priority = 1;
}

/// <summary>
/// Voice-only commentator playback. Add this to a scene object and assign original voice clips.
/// No commentator character, portrait or visible announcer is created.
/// </summary>
[RequireComponent(typeof(AudioSource))]
public class PrototypeCommentatorManager : MonoBehaviour
{
    [SerializeField] bool commentaryEnabled = true;
    [SerializeField, Range(0f, 1f)] float volume = 0.9f;
    [SerializeField] CommentatorLineSet[] lineSets;

    readonly List<QueuedLine> queue = new List<QueuedLine>();
    readonly Dictionary<StreetLegendEventType, float> nextAllowedTime = new Dictionary<StreetLegendEventType, float>();
    AudioSource voice;
    Coroutine playback;

    struct QueuedLine
    {
        public AudioClip Clip;
        public int Priority;
        public QueuedLine(AudioClip clip, int priority) { Clip = clip; Priority = priority; }
    }

    void Awake()
    {
        voice = GetComponent<AudioSource>();
        voice.playOnAwake = false;
        voice.loop = false;
        voice.spatialBlend = 0f; // commentator is a clear, non-diegetic voice
        voice.volume = volume;
    }

    void OnEnable() { StreetLegendGameplayEvents.Raised += HandleGameplayEvent; }
    void OnDisable()
    {
        StreetLegendGameplayEvents.Raised -= HandleGameplayEvent;
        queue.Clear();
        if (playback != null) StopCoroutine(playback);
        if (voice) voice.Stop();
    }

    void HandleGameplayEvent(StreetLegendGameEvent gameEvent)
    {
        if (!commentaryEnabled || lineSets == null) return;
        for (int i = 0; i < lineSets.Length; i++)
        {
            CommentatorLineSet set = lineSets[i];
            if (set == null || set.eventType != gameEvent.Type || set.voiceVariations == null || set.voiceVariations.Length == 0)
                continue;
            if (nextAllowedTime.TryGetValue(gameEvent.Type, out float allowedAt) && Time.time < allowedAt)
                return;

            AudioClip clip = PickClip(set.voiceVariations);
            if (!clip) return;
            nextAllowedTime[gameEvent.Type] = Time.time + set.cooldownSeconds;
            queue.Add(new QueuedLine(clip, set.priority));
            if (playback == null) playback = StartCoroutine(PlayQueue());
            return;
        }
    }

    AudioClip PickClip(AudioClip[] clips)
    {
        int validCount = 0;
        for (int i = 0; i < clips.Length; i++) if (clips[i]) validCount++;
        if (validCount == 0) return null;
        int selected = Random.Range(0, validCount);
        for (int i = 0; i < clips.Length; i++)
            if (clips[i] && selected-- == 0) return clips[i];
        return null;
    }

    IEnumerator PlayQueue()
    {
        while (queue.Count > 0)
        {
            int bestIndex = 0;\n            for (int i = 1; i < queue.Count; i++)\n                if (queue[i].Priority > queue[bestIndex].Priority) bestIndex = i;\n            QueuedLine line = queue[bestIndex];\n            queue.RemoveAt(bestIndex);
            if (!line.Clip) continue;
            voice.volume = volume;
            voice.clip = line.Clip;
            voice.Play();
            yield return new WaitWhile(() => voice && voice.isPlaying);
        }
        playback = null;
    }

    public void SetCommentaryEnabled(bool enabled)
    {
        commentaryEnabled = enabled;
        if (!enabled)
        {
            queue.Clear();
            if (voice) voice.Stop();
        }
    }

    public void SetVolume(float value)
    {
        volume = Mathf.Clamp01(value);
        if (voice) voice.volume = volume;
    }
}
