using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using FMODUnity;

public class MusicTrigger : MonoBehaviour
{
    [SerializeField] StudioEventEmitter MusicToFadeIn;
    [SerializeField] StudioEventEmitter MusicToFadeOut;
    [SerializeField] float MusicFadeTime;
    [SerializeField] float ReverbFadeTime;

    private StudioGlobalParameterTrigger GlobalParameter;

    private float FaderIn;
    private float FaderOut;

    // Start is called before the first frame update
    void Start()
    {
        GlobalParameter = GetComponent<StudioGlobalParameterTrigger>();

        FaderIn = 1.0f;
        FaderOut = 0.0f;
    }

    private IEnumerator FadeIn()
    {
        MusicToFadeIn.Play();
        while (FaderIn > 0.01f)
        {
            Mathf.Lerp(FaderIn, 0.0f, MusicFadeTime);
            MusicToFadeIn.SetParameter("Fade_out_in", FaderIn);
            yield return null;
        }
        FaderIn = 0.0f;
    }

    private IEnumerator FadeOut()
    {
        while (FaderOut < 0.99f)
        {
            Mathf.Lerp(FaderOut, 1.0f, MusicFadeTime);
            MusicToFadeOut.SetParameter("Fade_out_in", FaderOut);
            yield return null;
        }
        FaderOut = 1.0f;
        MusicToFadeOut.Stop();
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag.Equals("Player"))
        {
            print("bleepBloop");
            StartCoroutine(FadeIn());
            StartCoroutine(FadeOut());
        }
    }
}
