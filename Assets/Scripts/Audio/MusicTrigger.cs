using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FMODUnity;
using UnityEngine.SceneManagement;

public class MusicTrigger : MonoBehaviour
{
    public string FadeIn;
    public string FadeOut;
    private StudioEventEmitter MusicToFadeIn;
    private StudioEventEmitter MusicToFadeOut;

    // private void Start()
    // {
    //     MusicToFadeIn = GameObject.Find( FadeIn ).GetComponent<StudioEventEmitter>();
    //     MusicToFadeIn = GameObject.Find( FadeOut ).GetComponent<StudioEventEmitter>();
    // }

    // private void OnEnable()
    // {
    //     MusicToFadeIn = GameObject.Find( FadeIn ).GetComponent<StudioEventEmitter>();
    //     MusicToFadeIn = GameObject.Find( FadeOut ).GetComponent<StudioEventEmitter>();
    // }
    private void OnTriggerEnter(Collider other)
    {
        MusicToFadeIn = GameObject.Find( FadeIn ).GetComponent<StudioEventEmitter>();
        MusicToFadeOut = GameObject.Find( FadeOut ).GetComponent<StudioEventEmitter>();
        if ( other.tag.Equals( "Player" ) )
        {
            MusicToFadeOut.Stop();
            MusicToFadeIn.Play();
        }
    }
}
