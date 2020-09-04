using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu( fileName = "Audio Settings", menuName = "Settings/Audio" )]
public class AudioSettings : ScriptableObject
{
    [Range( 0, 1 )] public float MasterVolume;
    [Range( 0, 1 )] public float MusicVolume;
    [Range( 0, 1 )] public float SFXVolume;
}
