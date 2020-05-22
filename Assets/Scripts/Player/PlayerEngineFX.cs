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
    [SerializeField] private Renderer SwordRenderer;
    [SerializeField, ColorUsage( true, true )] private Color JumpMinChargeColor;
    [SerializeField, ColorUsage( true, true )] private Color JumpMaxChargeColor;
    [SerializeField, ColorUsage( true, true )] private Color JumpFullChargeFeedbackColor;
    [SerializeField] private ParticleSystem[] JetParticles;
    [SerializeField] private ParticleSystem DashChargeParticles;
    [SerializeField] private ParticleSystem DashJetParticles;
    [SerializeField] private ParticleSystem JumpChargeParticles;
    [SerializeField] private ParticleSystem JumpJetParticles;
    [SerializeField] private ParticleSystemRenderer JumpChargeParticleRenderer;
    [SerializeField] private ParticleSystemRenderer JumpJetParticleRenderer;
    [SerializeField] private Color JetDefaultColor;
    [SerializeField] private Color JetCarveColor;

    private CinemachineImpulseSource CameraShake;

    private float RPM;
    private float Thrust;
    private float Turn;

    private bool IsCarving;

    private bool IsDashing;
    private bool DashHasCharged;

    private bool IsCrouching;
    private bool JumpHasCharged;

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
        SetJumpChargeColor();
        PlayDashParticles();
        PlayJumpChargeParticles();
    }

    void PlayDashParticles()
    {
        if ( IsDashing )
        {
            if ( !DashHasCharged )
            {
                DashChargeParticles.Play();
                DashHasCharged = true;
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
            DashHasCharged = false;
        }
    }
    void PlayJumpChargeParticles()
    {
        if ( IsCrouching )
        {
            JumpChargeParticles.Play();
        }
        else if ( !IsCrouching )
        {
            JumpChargeParticles.Clear();
        }
    }

    //FIXME: This subscribes to a unity event via editor. These weird dependencies would be solved if Groundchecks were their own class
    //that this class could implement
    public void PlayJumpJetParticles()
    {
        JumpJetParticles.Play();
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

    void SetJumpChargeColor()
    {
        Color chargeColor = Color.Lerp( JumpMinChargeColor, JumpMaxChargeColor, ControllerYoshi02.JumpForceCharge );
        SwordRenderer.materials[1].SetColor( "_EmissionColor", chargeColor );
        JumpChargeParticleRenderer.trailMaterial.SetColor( "_EmissionColor", chargeColor );
        JumpJetParticleRenderer.trailMaterial.SetColor( "_EmissionColor", chargeColor );
        if ( ControllerYoshi02.JumpForceCharge >= 1 )
        {
            SwordRenderer.materials[1].SetColor( "_EmissionColor", JumpFullChargeFeedbackColor );
            JumpChargeParticleRenderer.trailMaterial.SetColor( "_EmissionColor", JumpFullChargeFeedbackColor );
            JumpJetParticleRenderer.trailMaterial.SetColor( "_EmissionColor", JumpFullChargeFeedbackColor );
        }
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

    public void SetCrouching(bool _crouching)
    {
        IsCrouching = _crouching;
    }
}
