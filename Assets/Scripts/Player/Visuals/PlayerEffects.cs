using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerEffects : MonoBehaviour
{
    [SerializeField]
    private ParticleSystem _laserEffects;

    internal void Damage(DamageTypes damageType)
    {
        if (damageType == DamageTypes.Laser)
            _laserEffects.Play();
    }
}
