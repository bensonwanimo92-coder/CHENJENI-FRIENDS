using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

/// <summary>
/// Owns the prototype round lifecycle: win/lose, pause and restart.
/// Uses a simple overlay so the first scene needs no prefab or EventSystem setup.
/// </summary>
public class PrototypeMatchManager : MonoBehaviour
{
    [SerializeField] PrototypeFighterController player;
    [SerializeField] PrototypeOpponent opponent;

    Canvas canvas;
    Image overlay;
    Text message;
    bool finished;
    bool paused;
    bool ending;

    void Awake() { BuildOverlay(); }

    public void SetFighters(PrototypeFighterController playerController, PrototypeOpponent enemyController)
    {
        player = playerController;
        opponent = enemyController;
    }

    void Update()
    {
        if (!finished && !paused && !ending)
        {
            if (player && player.Health <= 0f) StartCoroutine(EndAfterKnockout(false));
            else if (opponent && opponent.Health <= 0f) StartCoroutine(EndAfterKnockout(true));
        }

        if (finished)
        {
            if (Input.GetKeyDown(KeyCode.R) || AnyTouchBegan()) RestartRound();
            return;
        }

        if (Input.GetKeyDown(KeyCode.P) || (!paused && !ending && TouchPauseRequested()))
        {
            TogglePause();
            return;
        }

        if (paused && AnyTouchBegan())
            TogglePause();
    }

    IEnumerator EndAfterKnockout(bool won)
    {
        ending = true;
        // Leave enough unscaled time for the knockout pose and commentator callout to begin.
        yield return new WaitForSecondsRealtime(1.1f);
        FinishRound(won);
    }

    void FinishRound(bool won)
    {
        finished = true;
        Time.timeScale = 0f;
        overlay.gameObject.SetActive(true);
        message.text = won
            ? "VICTORY\nHotel lobby cleared\nTap anywhere or press R to fight again"
            : "DEFEAT\nYou were knocked out\nTap anywhere or press R to retry";
    }

    void TogglePause()
    {
        if (finished) return;
        paused = !paused;
        Time.timeScale = paused ? 0f : 1f;
        overlay.gameObject.SetActive(paused);
        message.text = "PAUSED\nTap anywhere or press P to resume";
    }

    bool TouchPauseRequested()
    {
        for (int i = 0; i < Input.touchCount; i++)
        {
            Touch touch = Input.GetTouch(i);
            if (touch.phase == TouchPhase.Began &&
                touch.position.x >= Screen.width * 0.86f &&
                touch.position.y >= Screen.height * 0.82f)
                return true;
        }
        return false;
    }

    bool AnyTouchBegan()
    {
        for (int i = 0; i < Input.touchCount; i++)
            if (Input.GetTouch(i).phase == TouchPhase.Began) return true;
        return false;
    }

    void RestartRound()
    {
        Time.timeScale = 1f;
        Scene active = SceneManager.GetActiveScene();
        SceneManager.LoadScene(active.name);
    }

    void BuildOverlay()
    {
        var root = new GameObject("Match State Overlay", typeof(RectTransform), typeof(Canvas), typeof(CanvasScaler));
        canvas = root.GetComponent<Canvas>();
        canvas.renderMode = RenderMode.ScreenSpaceOverlay;
        canvas.sortingOrder = 100;
        var scaler = root.GetComponent<CanvasScaler>();
        scaler.uiScaleMode = CanvasScaler.ScaleMode.ScaleWithScreenSize;
        scaler.referenceResolution = new Vector2(1920, 1080);
        scaler.matchWidthOrHeight = 0.5f;

        var panel = new GameObject("Overlay Panel", typeof(RectTransform), typeof(Image));
        panel.transform.SetParent(root.transform, false);
        var panelRect = panel.GetComponent<RectTransform>();
        panelRect.anchorMin = Vector2.zero;
        panelRect.anchorMax = Vector2.one;
        panelRect.offsetMin = Vector2.zero;
        panelRect.offsetMax = Vector2.zero;
        overlay = panel.GetComponent<Image>();
        overlay.color = new Color(0.015f, 0.025f, 0.045f, 0.88f);
        overlay.raycastTarget = false;

        var label = new GameObject("Match Message", typeof(RectTransform), typeof(Text));
        label.transform.SetParent(panel.transform, false);
        var rect = label.GetComponent<RectTransform>();
        rect.anchorMin = new Vector2(0.12f, 0.28f);
        rect.anchorMax = new Vector2(0.88f, 0.72f);
        rect.offsetMin = Vector2.zero;
        rect.offsetMax = Vector2.zero;
        message = label.GetComponent<Text>();
        message.font = Resources.GetBuiltinResource<Font>("Arial.ttf");
        message.fontSize = 46;
        message.fontStyle = FontStyle.Bold;
        message.alignment = TextAnchor.MiddleCenter;
        message.color = Color.white;
        message.text = "PAUSED";
        overlay.gameObject.SetActive(false);
    }

    void OnDisable() { Time.timeScale = 1f; }
}
