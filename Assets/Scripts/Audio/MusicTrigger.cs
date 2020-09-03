using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FMODUnity;

public class MusicTrigger : MonoBehaviour
{
    [SerializeField] StudioEventEmitter MusicToFadeIn;
    [SerializeField] StudioEventEmitter MusicToFadeOut;

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag.Equals("Player"))
        {
            MusicToFadeOut.Stop();
            MusicToFadeIn.Play();
        }
    }
}
