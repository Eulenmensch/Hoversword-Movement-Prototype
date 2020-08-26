using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerEffects : MonoBehaviour
{
    [SerializeField]
    private ParticleSystem _laserEffects;
    [SerializeField] ParticleSystem _healPickupEffect;

    private void OnEnable()
    {
        PlayerEvents.Instance.OnHeal += Heal;
    }

    internal void Damage(DamageTypes damageType)
    {
        if ( damageType == DamageTypes.Laser )
            _laserEffects.Play();
    }

    private void Heal()
    {
        _healPickupEffect.Play();
    }
}
