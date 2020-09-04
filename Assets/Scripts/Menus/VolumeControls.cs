using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class VolumeControls : MonoBehaviour
{
    [SerializeField] AudioSettings Settings;
    [SerializeField] Slider MasterSlider;
    [SerializeField] Slider MusicSlider;
    [SerializeField] Slider SFXSlider;

    FMOD.Studio.Bus Master;
    FMOD.Studio.Bus Music;
    FMOD.Studio.Bus SFX;

    private void Start()
    {
        MasterSlider.value = Settings.MasterVolume;
        MusicSlider.value = Settings.MusicVolume;
        SFXSlider.value = Settings.SFXVolume;

        Master = FMODUnity.RuntimeManager.GetBus( "bus:/Master" );
        Master.setVolume( Settings.MasterVolume );
        Music = FMODUnity.RuntimeManager.GetBus( "bus:/Master/Music" );
        Music.setVolume( Settings.MusicVolume );
        SFX = FMODUnity.RuntimeManager.GetBus( "bus:/Master/SFX" );
        SFX.setVolume( Settings.SFXVolume );
    }

    public void SetMasterVolume(float _volume)
    {
        Settings.MasterVolume = _volume;
        Master.setVolume( Settings.MasterVolume );
    }

    public void SetMusicVolume(float _volume)
    {
        Settings.MusicVolume = _volume;
        Music.setVolume( Settings.MusicVolume );
    }

    public void SetSFXVolume(float _volume)
    {
        Settings.SFXVolume = _volume;
        SFX.setVolume( Settings.SFXVolume );
    }
}
