using UnityEngine;
using System;

public class PlayerEvents : MonoBehaviour
{
    public static PlayerEvents Instance { get; private set; }

    void Awake()
    {
        if ( Instance != null && Instance != this )
        {
            Destroy( this );
        }
        else
        {
            Instance = this;
        }
    }

    public event Action OnJump;
    public void Jump() { OnJump?.Invoke(); }

    public event Action OnJumpCharge;
    public void StartJumpCharge() { OnJumpCharge?.Invoke(); }

    public event Action OnLand;
    public void Land() { OnLand?.Invoke(); }

    public event Action OnJumpCancel;
    public void JumpCancel() { OnJumpCancel?.Invoke(); }

    public event Action OnStartDashCharge;
    public void StartDashCharge() { OnStartDashCharge?.Invoke(); }

    public event Action OnStopDashCharge;
    public void StopDashCharge() { OnStopDashCharge?.Invoke(); }

    public event Action<float> OnStartDash;
    public void StartDash(float _duration) { OnStartDash?.Invoke( _duration ); }

    public event Action OnStopDash;
    public void StopDash() { OnStopDash?.Invoke(); }

    public event Action<float> OnStartCarve;
    public void StartCarve(float _direction) { OnStartCarve?.Invoke( _direction ); }

    public event Action OnStopCarve;
    public void StopCarve() { OnStopCarve?.Invoke(); }

    public event Action OnStartAim;
    public void StartAim() { OnStartAim?.Invoke(); }

    public event Action OnStopAim;
    public void StopAim() { OnStopAim?.Invoke(); }

    public event Action OnStartSlashAttack;
    public void StartSlashAttack() { OnStartSlashAttack?.Invoke(); }

    public event Action OnStopSlashAttack;
    public void StopSlashAttack() { OnStopSlashAttack?.Invoke(); }

    public event Action OnStartKickAttack;
    public void StartKickAttack() { OnStartKickAttack?.Invoke(); }

    public event Action OnStopKickAttack;
    public void StopKickAttack() { OnStopKickAttack?.Invoke(); }

    public event Action OnTakeDamage;
    public void TakeDamage() { OnTakeDamage?.Invoke(); }

    public event Action OnHeal;
    public void Heal() { OnHeal?.Invoke(); }

    public event Action<string> OnWallContact;
    public void WallContact(string _direction) { OnWallContact?.Invoke( _direction ); }
}