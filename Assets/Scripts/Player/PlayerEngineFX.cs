using System.Collections;
using System.Collections.Generic;
using UnityEngine;
// using FMOD.Studio;
// using FMODUnity;
using Cinemachine;

public class PlayerEngineFX : MonoBehaviour
{
    [SerializeField] private Rigidbody RB;
    [SerializeField] private PlayerHandling Handling;
    [SerializeField] private Renderer SwordRenderer;

    [Header( "Dash" )]
    [SerializeField] private PlayerDash Dash;
    [SerializeField] private ParticleSystem[] DashChargeParticles;
    [SerializeField] private ParticleSystem[] DashBoardParticles;
    [SerializeField] private ParticleSystem DashJetParticles;

    [Header( "Jump" )]
    [SerializeField] private PlayerJump Jump;
    [SerializeField, ColorUsage( true, true )] private Color JumpMinChargeColor;
    [SerializeField, ColorUsage( true, true )] private Color JumpMaxChargeColor;
    [SerializeField, ColorUsage( true, true )] private Color JumpFullChargeFeedbackColor;
    [SerializeField] private AnimationCurve JumpChargeSpinSpeed;
    [SerializeField] private ParticleSystem[] JumpChargeParticles;
    [SerializeField] private ParticleSystem JumpChargeSpinParticles;
    [SerializeField] private ParticleSystem JumpJetParticles;
    [SerializeField] private ParticleSystemRenderer JumpChargeParticleRenderer;
    [SerializeField] private ParticleSystemRenderer JumpJetParticleRenderer;

    [Header( "Driving" )]
    [SerializeField] private GameObject SpeedLines;
    [SerializeField] private Color JetDefaultColor;
    [SerializeField] private Color JetCarveColor;

    [Header( "Attacks" )]
    [SerializeField] private ParticleSystem[] FlipAttackParticles;
    [SerializeField] private ParticleSystem[] SlashAttackParticles;

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

    private void OnEnable()
    {
        PlayerEvents.Instance.OnStartKickAttack += PlayKickAttackParticles;
        PlayerEvents.Instance.OnStartSlashAttack += PlaySlashAttackParticles;
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
                if ( dashChargeParticle != null )
                {
                    var main = dashChargeParticle.main;
                    main.simulationSpeed = ( 1.0f / Dash.ChargeTime );
                }
            }

        }
        else
        {
            foreach ( var dashChargeParticle in DashChargeParticles )
            {
                if ( dashChargeParticle != null )
                {
                    var main = dashChargeParticle.main;
                    main.simulationSpeed = 0.0f;
                }
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
                    if ( dashChargeParticle != null )
                    {
                        dashChargeParticle.Play();
                    }
                }
                DashChargeStarted = true;
            }
        }
        else
        {
            foreach ( var dashChargeParticle in DashChargeParticles )
            {
                if ( dashChargeParticle != null )
                {
                    dashChargeParticle.Stop();
                }
            }
            DashChargeStarted = false;
        }
    }

    void PlayDashJetParticles()
    {
        if ( DashJetParticles != null )
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
    }

    void PlayDashBoardParticles()
    {
        if ( ( Handling.IsDashing && !DashIsPlaying ) || ( Dash.IsCharging && !DashChargeStarted ) )
        {
            foreach ( var dashBoardParticle in DashBoardParticles )
            {
                if ( dashBoardParticle != null )
                {
                    dashBoardParticle.Play();
                }
            }
            DashIsPlaying = true;
        }
        else if ( !Handling.IsDashing && !Dash.IsCharging )
        {
            foreach ( var dashBoardParticle in DashBoardParticles )
            {
                if ( dashBoardParticle != null )
                {
                    dashBoardParticle.Stop();
                }
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
                if ( system != null )
                {
                    system.Play();
                }
            }
            JumpHasCharged = true;
        }
        else if ( !IsCrouching )
        {
            foreach ( var system in JumpChargeParticles )
            {
                if ( system != null )
                {
                    system.Stop();
                    system.Clear();
                }
            }
            JumpHasCharged = false;
        }
    }

    public void PlayJumpJetParticles()
    {
        if ( JumpJetParticles != null )
        {
            JumpJetParticles.Play();
        }
    }

    void PlayKickAttackParticles()
    {
        foreach ( var system in FlipAttackParticles )
        {
            if ( system != null )
            {
                system.Play();
            }
        }
    }

    void PlaySlashAttackParticles()
    {
        foreach ( var system in SlashAttackParticles )
        {
            if ( system != null )
            {
                system.Play();
            }
        }
    }

    void SetJetParticleParameters()
    {

    }

    void SetJumpChargeSpinSpeed()
    {
        if ( JumpChargeSpinParticles != null )
        {
            var rotation = JumpChargeSpinParticles.rotationOverLifetime;
            var value = JumpChargeSpinSpeed.Evaluate( Jump.JumpForceCharge );
            rotation.yMultiplier = value;
        }
    }

    void SetJumpChargeColor()
    {
        if ( JumpChargeParticleRenderer != null && JumpJetParticleRenderer != null && SwordRenderer != null )
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
