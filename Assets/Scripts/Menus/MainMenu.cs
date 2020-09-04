using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class MainMenu : MonoBehaviour
{
    public void StartGame()
    {
        SceneManager.LoadSceneAsync( 1 );
    }

    public void LoadSettings()
    {
        SceneManager.LoadSceneAsync( "Pause Menu", LoadSceneMode.Additive );
    }

    public void Exit()
    {
        Application.Quit();
    }
}
