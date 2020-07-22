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
    [SerializeField, ColorUsage( true, true )] private Color JumpMinChargeColor;
    [SerializeField, ColorUsage( true, true )] private Color JumpMaxChargeColor;
    [SerializeField, ColorUsage( true, true )] private Color JumpFullChargeFeedbackColor;
    [SerializeField] private ParticleSystem[] MainBoosters;
    [SerializeField] private ParticleSystem[] OuterCircles;
    [SerializeField] private ParticleSystem[] Sparks;
    [SerializeField] private ParticleSystem[] ThrusterTrails;
    [SerializeField] private ParticleSystem DashChargeParticles;
    [SerializeField] private ParticleSystem DashJetParticles;
    [SerializeField] private ParticleSystem JumpChargeParticles;
    [SerializeField] private ParticleSystem JumpJetParticles;
    [SerializeField] private GameObject SpeedLines;
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
    private bool DashChargeStarted;

    private bool IsCrouching;
    private bool JumpHasCharged;

    private float DefaultStartLifetime;
    private ParticleSystem DefaultMainBooster;
    private ParticleSystem DefaultOuterCircle;
    private ParticleSystem DefaultSpark;
    private ParticleSystem DefaultThrusterTrail;

    private void Awake()
    {
        DefaultMainBooster = MainBoosters[0];
        DefaultOuterCircle = OuterCircles[0];
        DefaultSpark = Sparks[0];
        DefaultThrusterTrail = ThrusterTrails[0];
        CameraShake = GetComponent<CinemachineImpulseSource>();
    }

    private void Start()
    {
        SetDashChargeParticleDuration();
    }

    void Update()
    {
        SetJetParticleParameters();
        SetJumpChargeColor();
        PlayDashChargeParticles();
        PlayDashJetParticles();
        PlayJumpChargeParticles();
        SetSpeedlinePosition();
    }

    void SetDashChargeParticleDuration()
    {
        float chargeTime = Dash.ChargeTime;
        if ( chargeTime != 0 )
        {
            var main = DashChargeParticles.main;
            main.simulationSpeed = ( 1.0f / Dash.ChargeTime );
        }
        else
        {
            var main = DashChargeParticles.main;
            main.simulationSpeed = 0.0f;
        }
    }
    void PlayDashChargeParticles()
    {
        if ( Dash.IsCharging )
        {
            if ( !DashChargeStarted )
            {
                DashChargeParticles.Play();
                DashChargeStarted = true;
            }
        }
        else
        {
            DashChargeParticles.Clear();
            DashChargeStarted = false;
        }
    }

    void PlayDashJetParticles()
    {
        if ( Handling.IsDashing )
        {
            DashJetParticles.Play();
        }
        else
        {
            DashJetParticles.Stop();
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
            JumpChargeParticles.Stop();
            JumpChargeParticles.Clear();
        }
    }

    public void PlayJumpJetParticles()
    {
        JumpJetParticles.Play();
    }

    void SetJetParticleParameters()
    {
        foreach ( var booster in MainBoosters )
        {
            var main = booster.main;
            main.startSizeZMultiplier = 0.5f + ( 1.5f * Thrust );
        }
        foreach ( var outerCircle in OuterCircles )
        {
            var main = outerCircle.main;
            main.startSizeZMultiplier = 0.8f + ( 2.2f * Thrust );
        }
        foreach ( var spark in Sparks )
        {
            var main = spark.main;
            main.startSizeMultiplier = 0.3f * Thrust;
            main.startSpeedMultiplier = 0.6f + ( 1.25f * Thrust );
            var emission = spark.emission;
            emission.rateOverTimeMultiplier = 35.0f * Thrust;
            var velOverTime = spark.velocityOverLifetime;
            velOverTime.zMultiplier = 2.8f * Thrust;
            var noise = spark.noise;
            noise.strengthMultiplier = 2.3f * Thrust;
            noise.frequency = 1.2f * Thrust;
            noise.scrollSpeedMultiplier = 5.4f * Thrust;
            noise.sizeAmount = new ParticleSystem.MinMaxCurve( 0.4f * Thrust );
        }
        foreach ( var trail in ThrusterTrails )
        {
            var main = trail.main;
            main.startSizeMultiplier = 0.15f + ( 0.85f * Thrust );
            var emission = trail.emission;
            emission.rateOverTimeMultiplier = 10.0f + ( 10.0f * Thrust );
        }
    }

    void SetJumpChargeColor()
    {
        Color chargeColor = Color.Lerp( JumpMinChargeColor, JumpMaxChargeColor, Jump.JumpForceCharge );
        SwordRenderer.materials[3].SetColor( "_EmissionColor", chargeColor );
        JumpChargeParticleRenderer.trailMaterial.SetColor( "_EmissionColor", chargeColor );
        JumpJetParticleRenderer.trailMaterial.SetColor( "_EmissionColor", chargeColor );
        if ( Jump.JumpForceCharge >= 1 )
        {
            SwordRenderer.materials[1].SetColor( "_EmissionColor", JumpFullChargeFeedbackColor );
            JumpChargeParticleRenderer.trailMaterial.SetColor( "_EmissionColor", JumpFullChargeFeedbackColor );
            JumpJetParticleRenderer.trailMaterial.SetColor( "_EmissionColor", JumpFullChargeFeedbackColor );
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
