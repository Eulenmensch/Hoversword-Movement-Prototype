using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerEffects : MonoBehaviour
{
    [SerializeField]
    private ParticleSystem _laserEffects;

    internal void LaserDamage()
    {
        _laserEffects.Play();
    }
}
