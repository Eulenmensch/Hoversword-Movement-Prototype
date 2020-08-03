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
    [SerializeField] private ParticleSystem[] DashChargeParticles;
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
                // dashChargeParticle.Clear();
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
