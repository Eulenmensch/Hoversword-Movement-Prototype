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
    // [SerializeField] private Renderer SwordRenderer;

    [Header("Dash")]
    [SerializeField] private PlayerDash Dash;
    [SerializeField] private ParticleSystem[] DashChargeParticles;
    [SerializeField] private ParticleSystem[] DashBoardParticles;
    [SerializeField] private ParticleSystem DashJetParticles;
    [SerializeField] private ParticleSystem[] DashDamageParticles;

    [Header("Jump")]
    [SerializeField] private PlayerJump Jump;
    [SerializeField, ColorUsage(true, true)] private Color JumpMinChargeColor;
    [SerializeField, ColorUsage(true, true)] private Color JumpMaxChargeColor;
    [SerializeField, ColorUsage(true, true)] private Color JumpFullChargeFeedbackColor;
    [SerializeField] private AnimationCurve JumpChargeSpinSpeed;
    [SerializeField] private ParticleSystem[] JumpChargeParticles;
    [SerializeField] private ParticleSystem JumpChargeSpinParticles;
    [SerializeField] private ParticleSystem JumpJetParticles;
    // [SerializeField] private ParticleSystemRenderer JumpChargeParticleRenderer;
    // [SerializeField] private ParticleSystemRenderer JumpJetParticleRenderer;

    [Header("Driving")]
    [SerializeField] private ParticleSystem Thruster;
    [SerializeField] private GameObject SpeedLines;
    [SerializeField] private ParticleSystem[] DustParticles;

    [Header("Carving")]
    [SerializeField] private ParticleSystem CarveSparksLeft;
    [SerializeField] private ParticleSystem CarveSparksRight;

    [Header("Wall Sparks")]
    [SerializeField] private ParticleSystem WallSparksLeft;
    [SerializeField] private ParticleSystem WallSparksRight;

    [Header("Attacks")]
    [SerializeField] private ParticleSystem[] FlipAttackParticles;
    [SerializeField] private ParticleSystem[] SlashAttackParticles;
    [SerializeField] private ParticleSystem[] SlashAimParticles;

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
        PlayerEvents.Instance.OnStartAim += PlaySlashAimParticles;
        PlayerEvents.Instance.OnStopAim += StopSlashAimParticles;

        PlayerEvents.Instance.OnStartCarve += PlayCarveSparkParticles;
        PlayerEvents.Instance.OnStopCarve += StopCarveSparkParticles;

        PlayerEvents.Instance.OnStartWallContact += PlayWallSparkParticles;
        PlayerEvents.Instance.OnUpdatetWallContact += UpdateWallSparkParticles;
        PlayerEvents.Instance.OnStopWallContact += StopWallSparkParticles;

        PlayerEvents.Instance.OnJumpCharge += SetCrouchingTrue;
        PlayerEvents.Instance.OnJump += SetCrouchingFalse;
        PlayerEvents.Instance.OnJumpCancel += SetCrouchingFalse;
        PlayerEvents.Instance.OnHandleJumpAfterAim += SetCrouchingFalse;
        PlayerEvents.Instance.OnLand += SetCrouchingFalse;

        PlayerEvents.Instance.OnTakeDashDamage += PlayDashDamageParticles;
        PlayerEvents.Instance.OnTakeDamage += PlayDashDamageParticles;
    }

    private void OnDisable()
    {
        PlayerEvents.Instance.OnStartKickAttack -= PlayKickAttackParticles;
        PlayerEvents.Instance.OnStartSlashAttack -= PlaySlashAttackParticles;
        PlayerEvents.Instance.OnStartAim -= PlaySlashAimParticles;
        PlayerEvents.Instance.OnStopAim -= StopSlashAimParticles;

        PlayerEvents.Instance.OnStartCarve -= PlayCarveSparkParticles;
        PlayerEvents.Instance.OnStopCarve -= StopCarveSparkParticles;

        PlayerEvents.Instance.OnStartWallContact -= PlayWallSparkParticles;
        PlayerEvents.Instance.OnUpdatetWallContact -= UpdateWallSparkParticles;
        PlayerEvents.Instance.OnStopWallContact -= StopWallSparkParticles;

        PlayerEvents.Instance.OnJumpCharge -= SetCrouchingTrue;
        PlayerEvents.Instance.OnJump -= SetCrouchingFalse;
        PlayerEvents.Instance.OnJumpCancel -= SetCrouchingFalse;
        PlayerEvents.Instance.OnHandleJumpAfterAim -= SetCrouchingFalse;
        PlayerEvents.Instance.OnLand -= SetCrouchingFalse;

        PlayerEvents.Instance.OnTakeDashDamage -= PlayDashDamageParticles;
        PlayerEvents.Instance.OnTakeDamage -= PlayDashDamageParticles;
    }

    private void Start()
    {
        SetDashChargeParticleDuration();
    }

    void Update()
    {
        SetJetParticleParameters();
        PlayDashChargeParticles();
        PlayDashJetParticles();
        PlayDashBoardParticles();
        SetJumpChargeSpinSpeed();
        PlayJumpChargeParticles();
        SetSpeedlinePosition();
        ToggleDustParticles();
    }

    void SetDashChargeParticleDuration()
    {
        float chargeTime = Dash.ChargeTime;
        if (chargeTime != 0)
        {
            foreach (var dashChargeParticle in DashChargeParticles)
            {
                if (dashChargeParticle != null)
                {
                    var main = dashChargeParticle.main;
                    main.simulationSpeed = (1.0f / Dash.ChargeTime);
                }
            }

        }
        else
        {
            foreach (var dashChargeParticle in DashChargeParticles)
            {
                if (dashChargeParticle != null)
                {
                    var main = dashChargeParticle.main;
                    main.simulationSpeed = 0.0f;
                }
            }
        }
    }
    void PlayDashChargeParticles()
    {
        if (Dash.IsCharging)
        {
            if (!DashChargeStarted)
            {
                foreach (var dashChargeParticle in DashChargeParticles)
                {
                    if (dashChargeParticle != null)
                    {
                        dashChargeParticle.Play();
                    }
                }
                DashChargeStarted = true;
            }
        }
        else
        {
            foreach (var dashChargeParticle in DashChargeParticles)
            {
                if (dashChargeParticle != null)
                {
                    dashChargeParticle.Stop();
                }
            }
            DashChargeStarted = false;
        }
    }

    void PlayDashJetParticles()
    {
        if (DashJetParticles != null)
        {
            if (Handling.IsDashing)
            {
                DashJetParticles.Play();
            }
            else if (!Handling.IsDashing)
            {
                DashJetParticles.Stop();
            }
        }
    }

    void PlayDashBoardParticles()
    {
        if ((Handling.IsDashing && !DashIsPlaying) || (Dash.IsCharging && !DashChargeStarted))
        {
            foreach (var dashBoardParticle in DashBoardParticles)
            {
                if (dashBoardParticle != null)
                {
                    dashBoardParticle.Play();
                }
            }
            DashIsPlaying = true;
        }
        else if (!Handling.IsDashing && !Dash.IsCharging)
        {
            foreach (var dashBoardParticle in DashBoardParticles)
            {
                if (dashBoardParticle != null)
                {
                    dashBoardParticle.Stop();
                }
            }
            DashIsPlaying = false;
        }
    }

    void PlayDashDamageParticles()
    {
        foreach (var system in DashDamageParticles)
        {
            system.Play();
        }
    }

    void PlayJumpChargeParticles()
    {
        if (IsCrouching && !JumpHasCharged)
        {
            foreach (var system in JumpChargeParticles)
            {
                if (system != null)
                {
                    system.Play();
                }
            }
            JumpHasCharged = true;
        }
        else if (!IsCrouching)
        {
            foreach (var system in JumpChargeParticles)
            {
                if (system != null)
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
        if (JumpJetParticles != null)
        {
            JumpJetParticles.Play();
        }
    }

    void PlayKickAttackParticles()
    {
        foreach (var system in FlipAttackParticles)
        {
            if (system != null)
            {
                system.Play();
            }
        }
    }

    void PlaySlashAttackParticles()
    {
        foreach (var system in SlashAttackParticles)
        {
            if (system != null)
            {
                system.Play();
            }
        }
    }

    void PlaySlashAimParticles()
    {
        foreach (var system in SlashAimParticles)
        {
            if (system != null)
                system.Play();
        }
    }

    void StopSlashAimParticles()
    {
        foreach (var system in SlashAimParticles)
        {
            if (system != null)
                system.Stop();
        }
    }

    void SetJetParticleParameters()
    {

    }

    void SetJumpChargeSpinSpeed()
    {
        if (JumpChargeSpinParticles != null)
        {
            var rotation = JumpChargeSpinParticles.rotationOverLifetime;
            var value = JumpChargeSpinSpeed.Evaluate(Jump.JumpForceCharge);
            rotation.yMultiplier = value;
        }
    }

    void SetSpeedlinePosition()
    {
        if (SpeedLines != null)
        {
            SpeedLines.transform.localPosition = Vector3.forward * Mathf.Lerp(-14.0f, -11.5f, RB.velocity.magnitude / Handling.MaxSpeed);
        }
    }

    void ToggleDustParticles()
    {
        if (Handling.IsGrounded)
        {
            foreach (var system in DustParticles)
            {
                if (system != null)
                {
                    if (!system.isPlaying)
                    {
                        system.Play();
                    }
                }
            }
        }
        else
        {
            foreach (var system in DustParticles)
            {
                if (system != null)
                {
                    if (system.isPlaying)
                    {
                        system.Stop();
                    }
                }
            }
        }
    }

    void PlayCarveSparkParticles(float _direction)
    {
        if (_direction < 0 && CarveSparksLeft != null)
        {
            CarveSparksLeft.Play();
        }
        else if (_direction > 0 && CarveSparksRight != null)
        {
            CarveSparksRight.Play();
        }
    }
    void StopCarveSparkParticles()
    {
        if (CarveSparksLeft != null)
            CarveSparksLeft.Stop();
        if (CarveSparksRight != null)
            CarveSparksRight.Stop();
    }

    void PlayWallSparkParticles()
    {
        if (WallSparksRight != null)
        {
            WallSparksRight.Play();
        }

    }
    void UpdateWallSparkParticles(Transform _collisionPoint)
    {
        if (WallSparksRight != null)
        {
            WallSparksRight.transform.position = _collisionPoint.position;
            WallSparksRight.transform.position += WallSparksRight.transform.forward * 0.1f;
            WallSparksRight.transform.rotation = _collisionPoint.rotation;
        }
    }
    void StopWallSparkParticles()
    {
        if (WallSparksLeft != null)
            WallSparksLeft.Stop();
        if (WallSparksRight != null)
            WallSparksRight.Stop();
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
        // IsCrouching = _crouching;
    }

    private void SetCrouchingTrue() { IsCrouching = true; }
    private void SetCrouchingFalse()
    {
        if (!Handling.IsJumpCharging)
        {
            IsCrouching = false;
        }
    }
}
