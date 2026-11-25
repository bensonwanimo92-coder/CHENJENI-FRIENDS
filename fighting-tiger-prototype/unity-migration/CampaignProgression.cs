using UnityEngine;
using UnityEngine.SceneManagement;

/// <summary>Simple four-stage campaign state and scene-loading bridge.
/// Wire UI buttons to StartLevel and campaign completion events in Unity.</summary>
public class CampaignProgression : MonoBehaviour
{
    public const int LevelCount = 4;
    [SerializeField] string[] sceneNames = { "Level1_Hotel", "Level2_Backstreets", "Level3_Hideout", "Level4_Slandon" };
    [SerializeField] int currentLevel = 1;

    public int CurrentLevel => currentLevel;
    public int TotalLevels => LevelCount;

    public void StartLevel(int level)
    {
        if (level < 1 || level > LevelCount || sceneNames == null || sceneNames.Length < LevelCount)
        {
            Debug.LogWarning("Invalid campaign level index or scene configuration.");
            return;
        }
        currentLevel = level;
        SceneManager.LoadScene(sceneNames[level - 1]);
    }

    public void CompleteCurrentLevel()
    {
        if (currentLevel >= LevelCount)
        {
            Debug.Log("Campaign complete: Odessa rescued. Trigger reunion sequence.");
            return;
        }
        StartLevel(currentLevel + 1);
    }
}
