using System.Collections;
using System.Collections.Generic;
using UnityEngine;
// using FMOD.Studio;
// using FMODUnity;
using Cinemachine;

public class PlayerEngineFX : MonoBehaviour
{
    // [SerializeField] private StudioEventEmitter EngineEmitter;
    // [SerializeField] private StudioEventEmitter ThrustersEmitter;
    [SerializeField] private Rigidbody RB;
    [SerializeField] private HoverBoardControllerYoshi02 ControllerYoshi02;
    [SerializeField] private ParticleSystem[] JetParticles;
    [SerializeField] private ParticleSystem DashChargeParticles;
    [SerializeField] private ParticleSystem DashJetParticles;
    [SerializeField] private Color JetDefaultColor;
    [SerializeField] private Color JetCarveColor;

    private CinemachineImpulseSource CameraShake;

    private float RPM;
    private float Thrust;
    private float Turn;

    private bool IsCarving;

    private bool IsDashing;
    private bool HasCharged;

    private float DefaultStartLifetime;

    private void Awake()
    {
        DefaultStartLifetime = JetParticles[0].startLifetime;
        CameraShake = GetComponent<CinemachineImpulseSource>();
    }

    void Update()
    {
        SetRPMParameter();
        SetThrustParameter();
        SetTurnParameter();
        SetJetParticleParameters();
        PlayDashParticles();
    }

    void PlayDashParticles()
    {
        if ( IsDashing )
        {
            if ( !HasCharged )
            {
                DashChargeParticles.Play();
                HasCharged = true;
            }
            if ( DashChargeParticles.isStopped )
            {
                DashJetParticles.Play();
                CameraShake.GenerateImpulse(); //FIXME: There should be a class for camera effects but for now this works.
            }
        }
        else
        {
            DashChargeParticles.Clear();
            DashJetParticles.Stop();
            HasCharged = false;
        }
    }

    void SetJetParticleParameters()
    {
        foreach ( var jetParticle in JetParticles )
        {
            jetParticle.startLifetime = DefaultStartLifetime * Thrust;
            if ( IsCarving )
            {
                jetParticle.startColor = JetCarveColor;
            }
            else if ( !IsCarving )
            {
                jetParticle.startColor = JetDefaultColor;
            }
        }
    }

    void SetRPMParameter()
    {
        // RPM = RB.velocity.magnitude / ControllerYoshi02.MaxSpeed;
        // EngineEmitter.SetParameter( "RPM", RPM );

    }

    void SetThrustParameter()
    {
        // ThrustersEmitter.SetParameter( "Thrust", Thrust );
    }

    void SetTurnParameter()
    {
        // EngineEmitter.SetParameter( "Turn", Turn );
    }



    public void SetMoveInput(float _thrust, float _turn)
    {
        Thrust = _thrust;
        Turn = _turn;
    }

    public void SetDashing(bool _dashing)
    {
        IsDashing = _dashing;
    }

    public void SetCarving(bool _carving)
    {
        IsCarving = _carving;
    }
}
