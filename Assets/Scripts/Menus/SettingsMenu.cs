using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class SettingsMenu : MonoBehaviour
{
    [SerializeField] Image Panel;
    public void LoadMainMenu()
    {
        SceneManager.LoadSceneAsync( "Main Menu" );
    }

    private void OnEnable()
    {
        if ( SceneManager.GetSceneByName( "Main Menu" ).isLoaded )
        {
            Panel.color = new Color( 0, 0, 0, 1 );
        }
        else
        {
            Panel.color = new Color( 0, 0, 0, 0.6f );
        }
    }

    public void Continue()
    {
        SceneManager.UnloadSceneAsync( "Pause Menu" );
        PlayerEvents.Instance.StopPause();
    }
}
