using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;

/// <summary>
/// Runtime Android touch layout and lightweight combat HUD.
/// Touches on the lower-left half steer; lower-right taps attack.
/// No EventSystem or prefab setup is required.
/// </summary>
[RequireComponent(typeof(PrototypeFighterController))]
public class PrototypeMobileHUD : MonoBehaviour
{
    [Header("Touch layout")]
    [SerializeField] float joystickRadius = 105f;
    [SerializeField] float joystickDeadZone = 12f;

    PrototypeFighterController player;
    PrototypeOpponent opponent;
    Canvas canvas;
    Image playerFill;
    Image opponentFill;
    Image joystickKnob;
    Vector2 joystickOrigin;
    int joystickFinger = -1;
    int attackFinger = -1;
    bool touchEnabled = true;
    PrototypeCommentatorManager commentator;
    Text voiceButtonText;
    Text subtitleButtonText;

    void Awake()
    {
        player = GetComponent<PrototypeFighterController>();
        opponent = player.Opponent;
        BuildInterface();
    }

    void Start()
    {
        commentator = FindObjectOfType<PrototypeCommentatorManager>();
    }

    void Update()
    {
        if (player == null) return;
        if (opponent == null) opponent = player.Opponent;

        if (playerFill) playerFill.fillAmount = Mathf.Clamp01(player.Health / 100f);
        if (opponentFill) opponentFill.fillAmount = opponent ? Mathf.Clamp01(opponent.Health / 100f) : 0f;

        if (!touchEnabled) return;
        for (int i = 0; i < Input.touchCount; i++)
        {
            Touch touch = Input.GetTouch(i);
            Vector2 pos = touch.position;

            if (touch.phase == TouchPhase.Began)
            {
                if (pos.x < Screen.width * 0.48f && pos.y < Screen.height * 0.62f && joystickFinger < 0)
                {
                    joystickFinger = touch.fingerId;
                    joystickOrigin = pos;
                    UpdateJoystick(pos);
                }
                else if (pos.x >= Screen.width * 0.52f && pos.y < Screen.height * 0.62f && attackFinger < 0)
                {
                    attackFinger = touch.fingerId;
                }
            }
            else if (touch.fingerId == joystickFinger &&
                     (touch.phase == TouchPhase.Moved || touch.phase == TouchPhase.Stationary))
            {
                UpdateJoystick(pos);
            }
            else if (touch.fingerId == joystickFinger &&
                     (touch.phase == TouchPhase.Ended || touch.phase == TouchPhase.Canceled))
            {
                joystickFinger = -1;
                player.SetMobileMoveInput(Vector2.zero);
                if (joystickKnob) joystickKnob.rectTransform.anchoredPosition = Vector2.zero;
            }
            else if (touch.fingerId == attackFinger &&
                     (touch.phase == TouchPhase.Ended || touch.phase == TouchPhase.Canceled))
            {
                if (touch.phase == TouchPhase.Ended)
                    player.TryAttack(pos.x >= Screen.width * 0.82f);
                attackFinger = -1;
            }
        }
    }

    void UpdateJoystick(Vector2 screenPosition)
    {
        Vector2 offset = Vector2.ClampMagnitude(screenPosition - joystickOrigin, joystickRadius);
        if (offset.magnitude < joystickDeadZone) offset = Vector2.zero;
        player.SetMobileMoveInput(offset / joystickRadius);
        if (joystickKnob) joystickKnob.rectTransform.anchoredPosition = offset;
    }

    void BuildInterface()
    {
        var root = new GameObject("Street Legend Mobile HUD", typeof(RectTransform), typeof(Canvas),
            typeof(CanvasScaler), typeof(GraphicRaycaster));
        canvas = root.GetComponent<Canvas>();
        canvas.renderMode = RenderMode.ScreenSpaceOverlay;
        canvas.sortingOrder = 20;
        var scaler = root.GetComponent<CanvasScaler>();
        scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
        scaler.referenceResolution = new Vector2(1920, 1080);
        scaler.matchWidthOrHeight = 0.5f;

        playerFill = MakeHealthBar(root.transform, "Player Health", new Vector2(0.04f, 0.93f), new Vector2(0.38f, 0.965f), new Color(0.12f, 0.72f, 0.92f));
        opponentFill = MakeHealthBar(root.transform, "Opponent Health", new Vector2(0.62f, 0.93f), new Vector2(0.96f, 0.965f), new Color(0.9f, 0.25f, 0.2f));

        MakePanel(root.transform, "Virtual Joystick Base", new Vector2(0.12f, 0.18f), new Vector2(0.12f, 0.18f), new Vector2(190, 190), new Color(0.08f, 0.13f, 0.2f, 0.42f));
        var knob = MakePanel(root.transform, "Virtual Joystick Knob", new Vector2(0.12f, 0.18f), new Vector2(0.12f, 0.18f), new Vector2(78, 78), new Color(0.2f, 0.72f, 0.92f, 0.82f));
        joystickKnob = knob.GetComponent<Image>();
        MakePanel(root.transform, "Light Attack Button", new Vector2(0.78f, 0.19f), new Vector2(0.78f, 0.19f), new Vector2(132, 132), new Color(0.08f, 0.55f, 0.78f, 0.82f));
        MakeLabel(root.transform, "LIGHT", new Vector2(0.78f, 0.19f), 26);
        MakePanel(root.transform, "Heavy Attack Button", new Vector2(0.91f, 0.29f), new Vector2(0.91f, 0.29f), new Vector2(148, 148), new Color(0.72f, 0.2f, 0.16f, 0.86f));
        MakeLabel(root.transform, "HEAVY", new Vector2(0.91f, 0.29f), 25);

        if (!FindObjectOfType<EventSystem>())
            new GameObject("Street Legend EventSystem", typeof(EventSystem), typeof(StandaloneInputModule));

        voiceButtonText = MakeSettingButton(root.transform, "VOICE ON", new Vector2(0.46f, 0.88f), ToggleVoice);
        subtitleButtonText = MakeSettingButton(root.transform, "SUBS OFF", new Vector2(0.56f, 0.88f), ToggleSubtitles);
    }

    Text MakeSettingButton(Transform parent, string value, Vector2 anchor, UnityEngine.Events.UnityAction action)
    {
        var go = new GameObject(value + " Button", typeof(RectTransform), typeof(Image), typeof(Button));
        go.transform.SetParent(parent, false);
        var rect = go.GetComponent<RectTransform>();
        rect.anchorMin = anchor;
        rect.anchorMax = anchor;
        rect.sizeDelta = new Vector2(150, 58);
        go.GetComponent<Image>().color = new Color(0.025f, 0.12f, 0.19f, 0.82f);
        var button = go.GetComponent<Button>();
        button.onClick.AddListener(action);

        var label = new GameObject("Label", typeof(RectTransform), typeof(Text));
        label.transform.SetParent(go.transform, false);
        var labelRect = label.GetComponent<RectTransform>();
        labelRect.anchorMin = Vector2.zero;
        labelRect.anchorMax = Vector2.one;
        labelRect.offsetMin = Vector2.zero;
        labelRect.offsetMax = Vector2.zero;
        var text = label.GetComponent<Text>();
        text.font = Resources.GetBuiltinResource<Font>("Arial.ttf");
        text.text = value;
        text.fontSize = 20;
        text.fontStyle = FontStyle.Bold;
        text.alignment = TextAnchor.MiddleCenter;
        text.color = Color.white;
        text.raycastTarget = false;
        return text;
    }

    void ToggleVoice()
    {
        if (!commentator) commentator = FindObjectOfType<PrototypeCommentatorManager>();
        if (!commentator) return;
        bool enabled = !voiceButtonText.text.Contains("OFF");
        commentator.SetCommentaryEnabled(!enabled);
        voiceButtonText.text = enabled ? "VOICE OFF" : "VOICE ON";
    }

    void ToggleSubtitles()
    {
        if (!commentator) commentator = FindObjectOfType<PrototypeCommentatorManager>();
        if (!commentator) return;
        bool enabled = !subtitleButtonText.text.Contains("ON");
        commentator.SetSubtitlesEnabled(!enabled);
        subtitleButtonText.text = enabled ? "SUBS OFF" : "SUBS ON";
    }

    Image MakeHealthBar(Transform parent, string name, Vector2 min, Vector2 max, Color fillColor)
    {
        var background = MakePanel(parent, name + " Background", min, max, Vector2.zero, new Color(0.025f, 0.04f, 0.07f, 0.78f));
        var fillObject = new GameObject(name + " Fill", typeof(RectTransform), typeof(Image));
        fillObject.transform.SetParent(background.transform, false);
        var rect = fillObject.GetComponent<RectTransform>();
        rect.anchorMin = Vector2.zero;
        rect.anchorMax = Vector2.one;
        rect.offsetMin = new Vector2(4, 4);
        rect.offsetMax = new Vector2(-4, -4);
        var fill = fillObject.GetComponent<Image>();
        fill.color = fillColor;
        fill.type = Image.Type.Filled;
        fill.fillMethod = Image.FillMethod.Horizontal;
        fill.fillOrigin = (int)Image.OriginHorizontal.Left;
        fill.fillAmount = 1f;
        return fill;
    }

    GameObject MakePanel(Transform parent, string name, Vector2 anchorMin, Vector2 anchorMax, Vector2 size, Color color)
    {
        var go = new GameObject(name, typeof(RectTransform), typeof(Image));
        go.transform.SetParent(parent, false);
        var rect = go.GetComponent<RectTransform>();
        rect.anchorMin = anchorMin;
        rect.anchorMax = anchorMax;
        rect.pivot = new Vector2(0.5f, 0.5f);
        rect.sizeDelta = size;
        rect.anchoredPosition = Vector2.zero;
        go.GetComponent<Image>().color = color;
        go.GetComponent<Image>().raycastTarget = false;
        return go;
    }

    void MakeLabel(Transform parent, string value, Vector2 anchor, int fontSize)
    {
        var go = new GameObject(value + " Label", typeof(RectTransform), typeof(Text));
        go.transform.SetParent(parent, false);
        var rect = go.GetComponent<RectTransform>();
        rect.anchorMin = anchor;
        rect.anchorMax = anchor;
        rect.sizeDelta = new Vector2(180, 54);
        var text = go.GetComponent<Text>();
        text.text = value;
        text.font = Resources.GetBuiltinResource<Font>("Arial.ttf");
        text.fontSize = fontSize;
        text.fontStyle = FontStyle.Bold;
        text.alignment = TextAnchor.MiddleCenter;
        text.color = Color.white;
        text.raycastTarget = false;
    }

    void OnDisable()
    {
        if (player) player.SetMobileMoveInput(Vector2.zero);
    }
}
