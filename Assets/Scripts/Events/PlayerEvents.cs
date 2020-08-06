using UnityEngine;
using System;

public class PlayerEvents : MonoBehaviour
{
    public static PlayerEvents Instance;

    private void Awake()
    {
        Instance = this;
    }

    public event Action OnJump;
    public void Jump() { OnJump?.Invoke(); }

    public event Action OnJumpCharge;
    public void StartJumpCharge() { OnJumpCharge?.Invoke(); }

    public event Action OnLand;
    public void Land() { OnLand?.Invoke(); }

    public event Action OnStartDashCharge;
    public void StartDashCharge() { OnStartDashCharge?.Invoke(); }

    public event Action OnStopDashCharge;
    public void StopDashCharge() { OnStopDashCharge?.Invoke(); }

    public event Action<float> OnStartDash;
    public void StartDash(float _duration) { OnStartDash?.Invoke(_duration); }

    public event Action OnStopDash;
    public void StopDash() { OnStopDash?.Invoke(); }

    public event Action OnStartCarve;
    public void StartCarve() { OnStartCarve?.Invoke(); }

    public event Action OnStopCarve;
    public void StopCarve() { OnStopCarve?.Invoke(); }
}