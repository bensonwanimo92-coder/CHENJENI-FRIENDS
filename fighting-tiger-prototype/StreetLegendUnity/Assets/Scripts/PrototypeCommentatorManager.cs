using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[System.Serializable]
public class CommentatorLineSet
{
    public StreetLegendEventType eventType;
    [TextArea] public string editorNotes;
    public AudioClip[] voiceVariations;
    [TextArea] public string[] textVariations;
    [Min(0f)] public float cooldownSeconds = 2f;
    [Range(0, 10)] public int priority = 1;
}

/// <summary>
/// Invisible, voice-only commentator. Uses assigned original clips when available
/// and Android system TextToSpeech as a runtime fallback. Optional subtitles are text only.
/// </summary>
[RequireComponent(typeof(AudioSource))]
public class PrototypeCommentatorManager : MonoBehaviour
{
    [SerializeField] bool commentaryEnabled = true;
    [SerializeField] bool subtitlesEnabled;
    [SerializeField, Range(0f, 1f)] float volume = 0.9f;
    [SerializeField, Range(0.75f, 1.25f)] float speechRate = 1.02f;
    [SerializeField, Range(0.75f, 1.25f)] float speechPitch = 0.98f;
    [SerializeField] float subtitleHoldSeconds = 3.2f;
    [SerializeField] CommentatorLineSet[] lineSets;

    readonly List<QueuedLine> queue = new List<QueuedLine>();
    readonly Dictionary<StreetLegendEventType, float> nextAllowedTime = new Dictionary<StreetLegendEventType, float>();
    AudioSource voice;
    Coroutine playback;
    Canvas subtitleCanvas;
    Text subtitleText;
    bool ttsReady;
    bool ttsConfigured;
    bool wasSpeaking;
    int utteranceNumber;
#if UNITY_ANDROID && !UNITY_EDITOR
    AndroidJavaObject androidTts;
#endif

    struct QueuedLine
    {
        public AudioClip Clip;
        public string Text;
        public int Priority;
        public QueuedLine(AudioClip clip, string text, int priority)
        { Clip = clip; Text = text; Priority = priority; }
    }

#if UNITY_ANDROID && !UNITY_EDITOR
    sealed class TtsInitListener : AndroidJavaProxy
    {
        readonly PrototypeCommentatorManager owner;
        public TtsInitListener(PrototypeCommentatorManager value)
            : base("android.speech.tts.TextToSpeech$OnInitListener") { owner = value; }
        public void onInit(int status) { owner.OnTtsInitialized(status); }
    }
#endif

    void Awake()
    {
        voice = GetComponent<AudioSource>();
        voice.playOnAwake = false;
        voice.loop = false;
        voice.spatialBlend = 0f;
        voice.volume = volume;
        if (lineSets == null || lineSets.Length == 0) lineSets = CreateDefaultLineSets();
        BuildSubtitleUI();
    }

    void Start()
    {
#if UNITY_ANDROID && !UNITY_EDITOR
        try
        {
            using (var unityPlayer = new AndroidJavaClass("com.unity3d.player.UnityPlayer"))
            using (var activity = unityPlayer.GetStatic<AndroidJavaObject>("currentActivity"))
                androidTts = new AndroidJavaObject("android.speech.tts.TextToSpeech", activity, new TtsInitListener(this));
        }
        catch (Exception exception)
        {
            Debug.LogWarning("Street Legend Android TTS could not initialize: " + exception.Message);
        }
#else
        // In Editor, subtitle and event-log output make the commentary system inspectable.
        ttsReady = true;
#endif
    }

    void Update()
    {
#if UNITY_ANDROID && !UNITY_EDITOR
        if (ttsReady && !ttsConfigured && androidTts != null)
        {
            try
            {
                using (var locale = new AndroidJavaClass("java.util.Locale"))
                using (var us = locale.GetStatic<AndroidJavaObject>("US"))
                {
                    androidTts.Call<int>("setLanguage", us);
                    androidTts.Call<int>("setSpeechRate", speechRate);
                    androidTts.Call<int>("setPitch", speechPitch);
                }
                ttsConfigured = true;
            }
            catch (Exception exception)
            {
                Debug.LogWarning("Street Legend TTS voice setup failed: " + exception.Message);
                ttsReady = false;
            }
        }
#endif
    }

    void OnTtsInitialized(int status) { ttsReady = status == 0; }

    void OnEnable() { StreetLegendGameplayEvents.Raised += HandleGameplayEvent; }

    void OnDisable()
    {
        StreetLegendGameplayEvents.Raised -= HandleGameplayEvent;
        queue.Clear();
        if (playback != null) StopCoroutine(playback);
        playback = null;
        if (voice) voice.Stop();
        StopSpeech();
        if (subtitleText) subtitleText.text = string.Empty;
    }

    void OnDestroy()
    {
#if UNITY_ANDROID && !UNITY_EDITOR
        if (androidTts != null)
        {
            try { androidTts.Call("shutdown"); androidTts.Dispose(); }
            catch (Exception) { }
            androidTts = null;
        }
#endif
    }

    void HandleGameplayEvent(StreetLegendGameEvent gameEvent)
    {
        if (!commentaryEnabled || lineSets == null) return;
        for (int i = 0; i < lineSets.Length; i++)
        {
            CommentatorLineSet set = lineSets[i];
            if (set == null || set.eventType != gameEvent.Type) continue;
            if (nextAllowedTime.TryGetValue(gameEvent.Type, out float allowedAt) && Time.time < allowedAt)
                return;

            AudioClip clip = PickClip(set.voiceVariations);
            string spokenText = PickText(set.textVariations);
            if (!clip && string.IsNullOrWhiteSpace(spokenText)) return;

            nextAllowedTime[gameEvent.Type] = Time.time + set.cooldownSeconds;
            queue.Add(new QueuedLine(clip, spokenText, set.priority));
            if (playback == null) playback = StartCoroutine(PlayQueue());
            return;
        }
    }

    AudioClip PickClip(AudioClip[] clips)
    {
        if (clips == null || clips.Length == 0) return null;
        var valid = new List<AudioClip>();
        foreach (AudioClip clip in clips) if (clip) valid.Add(clip);
        return valid.Count == 0 ? null : valid[UnityEngine.Random.Range(0, valid.Count)];
    }

    string PickText(string[] lines)
    {
        if (lines == null || lines.Length == 0) return null;
        var valid = new List<string>();
        foreach (string line in lines) if (!string.IsNullOrWhiteSpace(line)) valid.Add(line);
        return valid.Count == 0 ? null : valid[UnityEngine.Random.Range(0, valid.Count)];
    }

    IEnumerator PlayQueue()
    {
        while (queue.Count > 0)
        {
            int bestIndex = 0;
            for (int i = 1; i < queue.Count; i++)
                if (queue[i].Priority > queue[bestIndex].Priority) bestIndex = i;

            QueuedLine line = queue[bestIndex];
            queue.RemoveAt(bestIndex);

            if (line.Clip)
            {
                ShowSubtitle(line.Text);
                voice.volume = volume;
                voice.clip = line.Clip;
                voice.Play();
                yield return new WaitWhile(() => voice && voice.isPlaying);
            }
            else if (!string.IsNullOrWhiteSpace(line.Text))
            {
                ShowSubtitle(line.Text);
                Speak(line.Text);
                float timeout = Mathf.Clamp(line.Text.Length * 0.075f, 1.8f, 7f);
                float deadline = Time.realtimeSinceStartup + timeout;
                bool observedSpeech = false;
                while (Time.realtimeSinceStartup < deadline)
                {
                    bool speaking = IsSpeaking();
                    if (speaking) observedSpeech = true;
                    else if (observedSpeech) break;
                    yield return null;
                }
            }
        }
        playback = null;
    }

    void Speak(string text)
    {
#if UNITY_ANDROID && !UNITY_EDITOR
        if (androidTts != null && ttsReady)
        {
            try
            {
                using (var bundle = new AndroidJavaObject("android.os.Bundle"))
                    androidTts.Call<int>("speak", text, 0, bundle, "street-legend-" + (++utteranceNumber));
                wasSpeaking = true;
                return;
            }
            catch (Exception exception)
            {
                Debug.LogWarning("Street Legend TTS playback failed: " + exception.Message);
            }
        }
#endif
        Debug.Log("[Street Legend Commentator] " + text);
        wasSpeaking = false;
    }

    bool IsSpeaking()
    {
#if UNITY_ANDROID && !UNITY_EDITOR
        if (androidTts != null && ttsReady)
        {
            try { wasSpeaking = androidTts.Call<bool>("isSpeaking"); }
            catch (Exception) { wasSpeaking = false; }
        }
#endif
        return wasSpeaking;
    }

    void StopSpeech()
    {
#if UNITY_ANDROID && !UNITY_EDITOR
        if (androidTts != null)
        {
            try { androidTts.Call<int>("stop"); }
            catch (Exception) { }
        }
#endif
        wasSpeaking = false;
    }

    void BuildSubtitleUI()
    {
        var root = new GameObject("Voice Commentator Subtitles", typeof(RectTransform), typeof(Canvas), typeof(CanvasScaler));
        subtitleCanvas = root.GetComponent<Canvas>();
        subtitleCanvas.renderMode = RenderMode.ScreenSpaceOverlay;
        subtitleCanvas.sortingOrder = 30;
        var scaler = root.GetComponent<CanvasScaler>();
        scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
        scaler.referenceResolution = new Vector2(1920, 1080);

        var panel = new GameObject("Subtitle Backplate", typeof(RectTransform), typeof(Image));
        panel.transform.SetParent(root.transform, false);
        var panelRect = panel.GetComponent<RectTransform>();
        panelRect.anchorMin = new Vector2(0.12f, 0.075f);
        panelRect.anchorMax = new Vector2(0.88f, 0.17f);
        panelRect.offsetMin = Vector2.zero;
        panelRect.offsetMax = Vector2.zero;
        panel.GetComponent<Image>().color = new Color(0.015f, 0.025f, 0.04f, 0.78f);

        var label = new GameObject("Subtitle Text", typeof(RectTransform), typeof(Text));
        label.transform.SetParent(panel.transform, false);
        var rect = label.GetComponent<RectTransform>();
        rect.anchorMin = Vector2.zero;
        rect.anchorMax = Vector2.one;
        rect.offsetMin = new Vector2(18, 5);
        rect.offsetMax = new Vector2(-18, -5);
        subtitleText = label.GetComponent<Text>();
        subtitleText.font = Resources.GetBuiltinResource<Font>("Arial.ttf");
        subtitleText.fontSize = 28;
        subtitleText.alignment = TextAnchor.MiddleCenter;
        subtitleText.color = Color.white;
        subtitleText.horizontalOverflow = HorizontalWrapMode.Wrap;
        subtitleText.verticalOverflow = VerticalWrapMode.Truncate;
        root.SetActive(subtitlesEnabled);
    }

    void ShowSubtitle(string line)
    {
        if (!subtitleText || !subtitlesEnabled || string.IsNullOrWhiteSpace(line)) return;
        subtitleCanvas.gameObject.SetActive(true);
        subtitleText.text = line;
        CancelInvoke(nameof(ClearSubtitle));
        Invoke(nameof(ClearSubtitle), subtitleHoldSeconds);
    }

    void ClearSubtitle()
    {
        if (subtitleText) subtitleText.text = string.Empty;
    }

    CommentatorLineSet[] CreateDefaultLineSets()
    {
        return new[]
        {
            MakeLine(StreetLegendEventType.PlayerStartedMoving, 1.4f, 1, "He's on the move. Keep your guard up.", "He's closing the distance. Watch the footwork."),
            MakeLine(StreetLegendEventType.OpponentStartedMoving, 4.0f, 1, "The enforcer is advancing. Watch how he cuts the distance."),
            MakeLine(StreetLegendEventType.PlayerEnteredCombatRange, 1.8f, 2, "They're in striking range now. This is where timing matters.", "He's close enough to make this count."),
            MakeLine(StreetLegendEventType.PlayerLeftCombatRange, 2.5f, 1, "They've separated. Find the opening and step back in.", "The distance is growing. Reset and read your opponent."),
            MakeLine(StreetLegendEventType.PlayerAttackStarted, 1.1f, 2, "He's committing to the strike!", "Here comes the attack. Watch the timing."),
            MakeLine(StreetLegendEventType.PlayerAttackMissed, 1.5f, 2, "That one misses. He needs better distance.", "Swing and a miss. The opponent read that one."),
            MakeLine(StreetLegendEventType.PlayerHitConfirmed, 0.9f, 4, "Clean connection! That's how you make it count.", "A solid hit lands. He's finding his rhythm."),
            MakeLine(StreetLegendEventType.PlayerDamaged, 1.1f, 4, "He felt that one. Stay sharp!", "The opponent gets through the guard. He needs to respond."),
            MakeLine(StreetLegendEventType.OpponentStartedAttacking, 1.2f, 3, "Incoming attack! Read the opponent's movement.", "The enforcer is winding up. Be ready to evade."),
            MakeLine(StreetLegendEventType.OpponentDamaged, 1.2f, 2, "The enforcer is taking damage. Keep the pressure measured.", "That hit has an effect. The opponent is slowing down."),
            MakeLine(StreetLegendEventType.PlayerKnockedOut, 0f, 10, "He's down! The round is over.", "That's a knockout. He couldn't continue."),
            MakeLine(StreetLegendEventType.OpponentDefeated, 0f, 10, "The enforcer is down! That's a win.", "What a finish! The hotel lobby is clear.")
        };
    }

    CommentatorLineSet MakeLine(StreetLegendEventType type, float cooldown, int priority, params string[] lines)
    {
        return new CommentatorLineSet
        {
            eventType = type,
            cooldownSeconds = cooldown,
            priority = priority,
            textVariations = lines
        };
    }

    public void SetCommentaryEnabled(bool enabled)
    {
        commentaryEnabled = enabled;
        if (!enabled)
        {
            queue.Clear();
            if (voice) voice.Stop();
            StopSpeech();
            ClearSubtitle();
        }
    }

    public void SetSubtitlesEnabled(bool enabled)
    {
        subtitlesEnabled = enabled;
        if (subtitleCanvas) subtitleCanvas.gameObject.SetActive(enabled);
        if (!enabled) ClearSubtitle();
    }

    public void SetVolume(float value)
    {
        volume = Mathf.Clamp01(value);
        if (voice) voice.volume = volume;
    }

    public void SetSpeechRate(float value) { speechRate = Mathf.Clamp(value, 0.75f, 1.25f); }
    public void SetSpeechPitch(float value) { speechPitch = Mathf.Clamp(value, 0.75f, 1.25f); }
}
