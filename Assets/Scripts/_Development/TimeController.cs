using System.Collections;
using System.Collections.Generic;
#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine;
using UnityEngine.SceneManagement;

public class TimeController : MonoBehaviour
{
    [ShowOnly, SerializeField]
    private float timeScale = 1f;
    [ShowOnly, SerializeField]
    private float gameTime;
    private float[] timeScaleSteps = new float[] { 0.25f, 0.5f, 0.75f, 1f, 1.5f, 2f, 3f, 4f, 5f };
    private int currentTimeScaleStep = 3;

    [Header("Fixed Update Frame Stopping")]
    public bool stopFrame;
    public int frameStep;
    int currentFrame = 0;
    //[ShowOnly, SerializeField]
    //public int frames = 0;
    [ShowOnly, SerializeField]
    int fixedframes = 0;

    void Update()
    {
        //frames++;

        gameTime = Time.time;

        
        if (Input.GetKeyDown(KeyCode.R))
        {
            SceneManager.LoadScene(SceneManager.GetActiveScene().name);
        }

        if (Input.GetKeyDown(KeyCode.Escape))
        {
            Application.Quit();
        }
        
        
        // Pause Time with F3
        if (Input.GetKeyDown(KeyCode.F6))
        {
            if (timeScale != 0)
            {
                timeScale = 0;
            }
            else
            {
                timeScale = timeScaleSteps[currentTimeScaleStep];
            }
        }

        
        // Make Time run faster and slower with F1 and F2
        if (Input.GetKeyDown(KeyCode.F5))
        {
            currentTimeScaleStep = currentTimeScaleStep > 0 ? currentTimeScaleStep - 1 : 0;

            timeScale = timeScaleSteps[currentTimeScaleStep];
        }

        if (Input.GetKeyDown(KeyCode.F7))
        {
            currentTimeScaleStep = currentTimeScaleStep < timeScaleSteps.Length - 1 ? currentTimeScaleStep + 1 : timeScaleSteps.Length - 1;
            timeScale = timeScaleSteps[currentTimeScaleStep];
        }
        

        Time.timeScale = timeScale;

        // Pause Runtime when Frame Stop is enabled

//        if (stopFrame && !useFixedUpdate)
//        {
//            currentFrame++;

//            if (currentFrame >= frameStep)
//            {
//#if UNITY_EDITOR
//                EditorApplication.isPaused = true;
//#endif
//                currentFrame = 0;
//            }
//        }
//        */
    }

    private void FixedUpdate()
    {
        fixedframes++;

        if (stopFrame/* && useFixedUpdate*/)
        {
            currentFrame++;

            if (currentFrame >= frameStep)
            {
#if UNITY_EDITOR
                EditorApplication.isPaused = true;
#endif
                currentFrame = 0;
            }
        }
        
    }
}
