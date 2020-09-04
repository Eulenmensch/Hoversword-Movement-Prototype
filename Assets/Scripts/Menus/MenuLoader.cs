using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.InputSystem;

public class MenuLoader : MonoBehaviour
{
    public void LoadPauseMenu(InputAction.CallbackContext context)
    {
        if ( context.performed )
        {
            if ( !SceneManager.GetSceneByName( "Pause Menu" ).isLoaded )
            {
                SceneManager.LoadSceneAsync( "Pause Menu", LoadSceneMode.Additive );
                PlayerEvents.Instance.StartPause();
            }
            else
            {
                SceneManager.UnloadSceneAsync( "Pause Menu" );
                PlayerEvents.Instance.StopPause();
            }
        }
    }
}
