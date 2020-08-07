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
    [SerializeField] private PlayerHandling Handling;
    [SerializeField] private PlayerDash Dash;
    [SerializeField] private PlayerJump Jump;
    [SerializeField] private Renderer SwordRenderer;

    [SerializeField] private ParticleSystem[] DashChargeParticles;
    [SerializeField] private ParticleSystem[] DashBoardParticles;
    [SerializeField] private ParticleSystem DashJetParticles;
    [Header( "Jump" )]
    [SerializeField, ColorUsage( true, true )] private Color JumpMinChargeColor;
    [SerializeField, ColorUsage( true, true )] private Color JumpMaxChargeColor;
    [SerializeField, ColorUsage( true, true )] private Color JumpFullChargeFeedbackColor;
    [SerializeField] private AnimationCurve JumpChargeSpinSpeed;
    [SerializeField] private ParticleSystem[] JumpChargeParticles;
    [SerializeField] private ParticleSystem JumpChargeSpinParticles;
    [SerializeField] private ParticleSystem JumpJetParticles;
    [SerializeField] private ParticleSystemRenderer JumpChargeParticleRenderer;
    [SerializeField] private ParticleSystemRenderer JumpJetParticleRenderer;
    [SerializeField] private GameObject SpeedLines;
    [SerializeField] private Color JetDefaultColor;
    [SerializeField] private Color JetCarveColor;

    private CinemachineImpulseSource CameraShake;

    private float RPM;
    private float Thrust;
    private float Turn;

    private bool IsCarving;

    private bool IsDashing;
    private bool DashChargeStarted;
    private bool DashIsPlaying;

    private bool IsCrouching;
    private bool JumpHasCharged;

    private float DefaultStartLifetime;
    private ParticleSystem DefaultMainBooster;
    private ParticleSystem DefaultOuterCircle;
    private ParticleSystem DefaultSpark;
    private ParticleSystem DefaultThrusterTrail;

    private void Awake()
    {
        CameraShake = GetComponent<CinemachineImpulseSource>();
    }

    private void Start()
    {
        SetDashChargeParticleDuration();
    }

    void Update()
    {
        SetJetParticleParameters();
        //SetJumpChargeColor();
        PlayDashChargeParticles();
        PlayDashJetParticles();
        PlayDashBoardParticles();
        SetJumpChargeSpinSpeed();
        PlayJumpChargeParticles();
        SetSpeedlinePosition();
    }

    void SetDashChargeParticleDuration()
    {
        float chargeTime = Dash.ChargeTime;
        if ( chargeTime != 0 )
        {
            foreach ( var dashChargeParticle in DashChargeParticles )
            {
                var main = dashChargeParticle.main;
                main.simulationSpeed = ( 1.0f / Dash.ChargeTime );
            }

        }
        else
        {
            foreach ( var dashChargeParticle in DashChargeParticles )
            {
                var main = dashChargeParticle.main;
                main.simulationSpeed = 0.0f;
            }
        }
    }
    void PlayDashChargeParticles()
    {
        if ( Dash.IsCharging )
        {
            if ( !DashChargeStarted )
            {
                foreach ( var dashChargeParticle in DashChargeParticles )
                {
                    dashChargeParticle.Play();
                }
                DashChargeStarted = true;
            }
        }
        else
        {
            foreach ( var dashChargeParticle in DashChargeParticles )
            {
                dashChargeParticle.Stop();
            }
            DashChargeStarted = false;
        }
    }

    void PlayDashJetParticles()
    {
        if ( Handling.IsDashing )
        {
            DashJetParticles.Play();
        }
        else if ( !Handling.IsDashing )
        {
            DashJetParticles.Stop();
        }
    }

    void PlayDashBoardParticles()
    {
        if ( ( Handling.IsDashing && !DashIsPlaying ) || ( Dash.IsCharging && !DashChargeStarted ) )
        {
            foreach ( var dashBoardParticle in DashBoardParticles )
            {
                dashBoardParticle.Play();
            }
            DashIsPlaying = true;
        }
        else if ( !Handling.IsDashing && !Dash.IsCharging )
        {
            foreach ( var dashBoardParticle in DashBoardParticles )
            {
                dashBoardParticle.Stop();
            }
            DashIsPlaying = false;
        }
    }

    void PlayJumpChargeParticles()
    {
        if ( IsCrouching && !JumpHasCharged )
        {
            foreach ( var system in JumpChargeParticles )
            {
                system.Play();
            }
            JumpHasCharged = true;
        }
        else if ( !IsCrouching )
        {
            foreach ( var system in JumpChargeParticles )
            {
                system.Stop();
                system.Clear();
            }
            JumpHasCharged = false;
        }
    }

    public void PlayJumpJetParticles()
    {
        JumpJetParticles.Play();
    }

    void SetJetParticleParameters()
    {

    }

    void SetJumpChargeSpinSpeed()
    {
        var rotation = JumpChargeSpinParticles.rotationOverLifetime;
        var value = JumpChargeSpinSpeed.Evaluate( Jump.JumpForceCharge );
        rotation.yMultiplier = value;
    }

    void SetJumpChargeColor()
    {
        Color chargeColor = Color.Lerp( JumpMinChargeColor, JumpMaxChargeColor, Jump.JumpForceCharge );
        SwordRenderer.materials[3].SetColor( "_EmissionColor", chargeColor );
        JumpChargeParticleRenderer.material.SetColor( "_EmissionColor", chargeColor );
        JumpJetParticleRenderer.material.SetColor( "_EmissionColor", chargeColor );
        if ( Jump.JumpForceCharge >= 1 )
        {
            SwordRenderer.materials[1].SetColor( "_EmissionColor", JumpFullChargeFeedbackColor );
            JumpChargeParticleRenderer.material.SetColor( "_EmissionColor", JumpFullChargeFeedbackColor );
            JumpJetParticleRenderer.material.SetColor( "_EmissionColor", JumpFullChargeFeedbackColor );
        }
    }

    void SetSpeedlinePosition()
    {
        if ( SpeedLines != null )
        {
            SpeedLines.transform.localPosition = Vector3.forward * Mathf.Lerp( -14.0f, -11.5f, RB.velocity.magnitude / Handling.MaxSpeed );
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
