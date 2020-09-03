using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;

public class ScreenshakeController : MonoBehaviour
{
    // [SerializeField] float LandShakeAmount;
    [SerializeField] float DamageShakeAmount;
    [SerializeField] float DeathShakeAmount;

    private CinemachineImpulseSource ImpulseSource;

    private void OnEnable()
    {
        // PlayerEvents.Instance.OnLand += LandShake;
        PlayerEvents.Instance.OnTakeDamage += DamageShake;
        PlayerEvents.Instance.OnDeath += DeathShake;
    }

    private void Start()
    {
        ImpulseSource = GetComponent<CinemachineImpulseSource>();
    }

    // private void LandShake()
    // {
    //     ImpulseSource.GenerateImpulse(Vector3.down * LandShakeAmount);
    // }

    private void DamageShake()
    {
        ImpulseSource.GenerateImpulse(DamageShakeAmount);
    }

    private void DeathShake()
    {
        ImpulseSource.GenerateImpulse(DeathShakeAmount);
    }
}
