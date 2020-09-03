using UnityEngine;
using FMODUnity;
using System.Collections;

public class PlayerSounds : MonoBehaviour
{
    [SerializeField] PlayerHandling Handling;
    private PlayerHealth Health;

    [Header("Engine")]
    [SerializeField] StudioEventEmitter Engine;
    [SerializeField] StudioEventEmitter DriftBoost;
    [SerializeField] StudioEventEmitter Boost;

    [Header("Jump")]
    [SerializeField] StudioEventEmitter JumpCharge;
    [SerializeField] StudioEventEmitter JumpCharged;
    [SerializeField] StudioEventEmitter Jump;

    [Header("Attacks")]
    [SerializeField] StudioEventEmitter Kick;
    [SerializeField] StudioEventEmitter BladeModeOn;
    [SerializeField] StudioEventEmitter BladeModeOff;
    [SerializeField] StudioEventEmitter Slash;

    [Header("Health")]
    [SerializeField] StudioEventEmitter HealthGain;
    [SerializeField] StudioEventEmitter TakeDamage;
    [SerializeField] StudioEventEmitter Death;

    [Header("Environment Interaction")]
    private GameObject WallCollisionObject;
    [SerializeField] StudioEventEmitter WallCollision;
    [SerializeField] StudioEventEmitter Explosion;
    [SerializeField] StudioEventEmitter Checkpoint;


    private void OnEnable()
    {
        PlayerEvents.Instance.OnStartDashCharge += PlayBoostSound;
        PlayerEvents.Instance.OnStopDashCharge += CancelBoostSound;
        PlayerEvents.Instance.OnStopDash += StopBoostSound;

        PlayerEvents.Instance.OnStopCarve += StopDrifting;
        // PlayerEvents.Instance.OnStopCarve += PlayDriftBoostSound;
        // PlayerEvents.Instance.OnStartDash += StopDriftBoostSound;

        PlayerEvents.Instance.OnJumpCharge += PlayJumpChargeSound;
        PlayerEvents.Instance.OnJumpCharged += PlayJumpChargedSound;
        PlayerEvents.Instance.OnJump += PlayJumpSound;
        PlayerEvents.Instance.OnJump += StopJumpChargeSound;
        PlayerEvents.Instance.OnHandleJumpAfterAim += StopJumpChargeSound;

        PlayerEvents.Instance.OnLand += PlayJumpSound; //FIXME: I random pitched the sound so it doesn't sound too weird when also used as a landing sound

        PlayerEvents.Instance.OnStartKickAttack += PlayKickSound;
        PlayerEvents.Instance.OnStopKickAttack += StopKickSound;
        PlayerEvents.Instance.OnStartAim += PlayBladeModeOnSound;
        PlayerEvents.Instance.OnStartSlashAttack += PlaySlashSound;
        PlayerEvents.Instance.OnStopSlashAttack += StopSlashSound;

        PlayerEvents.Instance.OnHeal += PlayHealthGainSound;
        PlayerEvents.Instance.OnTakeDamage += PlayHurtSound;
        PlayerEvents.Instance.OnDeath += PlayDeathSound;

        PlayerEvents.Instance.OnStartWallContact += PlayWallCollisionSound;
        PlayerEvents.Instance.OnUpdatetWallContact += UpdateWallCollisionSound;
        PlayerEvents.Instance.OnStopWallContact += StopWallCollisionSound;
        PlayerEvents.Instance.OnExplosion += PlayExplosionSound;
        PlayerEvents.Instance.OnCheckpoint += PlayCheckpointSoud;
    }

    private void OnDisable()
    {
        PlayerEvents.Instance.OnStartDashCharge -= PlayBoostSound;
        PlayerEvents.Instance.OnStopDashCharge -= CancelBoostSound;
        PlayerEvents.Instance.OnStopDash -= StopBoostSound;

        PlayerEvents.Instance.OnStopCarve -= StopDrifting;
        // PlayerEvents.Instance.OnStopCarve -= PlayDriftBoostSound;
        // PlayerEvents.Instance.OnStartDash -= StopDriftBoostSound;

        PlayerEvents.Instance.OnJumpCharge -= PlayJumpChargeSound;
        PlayerEvents.Instance.OnJumpCharged -= PlayJumpChargedSound;
        PlayerEvents.Instance.OnJump -= PlayJumpSound;
        PlayerEvents.Instance.OnJump -= StopJumpChargeSound;
        PlayerEvents.Instance.OnHandleJumpAfterAim -= StopJumpChargeSound;

        PlayerEvents.Instance.OnLand -= PlayJumpSound; //FIXME: I random pitched the sound so it doesn't sound too weird when also used as a landing sound

        PlayerEvents.Instance.OnStartKickAttack -= PlayKickSound;
        PlayerEvents.Instance.OnStopKickAttack -= StopKickSound;
        PlayerEvents.Instance.OnStartAim -= PlayBladeModeOnSound;
        PlayerEvents.Instance.OnStartSlashAttack -= PlaySlashSound;
        PlayerEvents.Instance.OnStopSlashAttack -= StopSlashSound;

        PlayerEvents.Instance.OnHeal -= PlayHealthGainSound;
        PlayerEvents.Instance.OnTakeDamage -= PlayHurtSound;
        PlayerEvents.Instance.OnDeath -= PlayDeathSound;

        PlayerEvents.Instance.OnStartWallContact -= PlayWallCollisionSound;
        PlayerEvents.Instance.OnUpdatetWallContact -= UpdateWallCollisionSound;
        PlayerEvents.Instance.OnStopWallContact -= StopWallCollisionSound;
        PlayerEvents.Instance.OnExplosion -= PlayExplosionSound;
        PlayerEvents.Instance.OnCheckpoint -= PlayCheckpointSoud;
    }

    private void Start()
    {
        Health = FindObjectOfType<PlayerHealth>();
        WallCollisionObject = WallCollision.gameObject;
    }
    private void Update()
    {
        SetEngineParameters();
    }

    private void SetEngineParameters()
    {
        float speed = 0;
        PhysicsUtilities.ScaleValueWithSpeed(ref speed, 0, 1, Handling.RB, Handling.MaxSpeed);
        Engine.SetParameter("Speed", speed);

        Engine.SetParameter("Force", Handling.ThrustInput);

        if (Handling.IsCarving)
        {
            float driftAmount = Mathf.Clamp(Mathf.Abs(Handling.TurnInput), 0.4f, 1.0f);
            Engine.SetParameter("Drift", driftAmount);
        }
    }

    private void StopDrifting()
    {
        Engine.SetParameter("Drift", 0.0f);
    }

    private void PlayBoostSound() { Boost?.Play(); }
    private void CancelBoostSound()
    {
        if (!Handling.IsDashing)
        {
            Boost?.Stop();
        }
    }
    private void StopBoostSound() { Boost?.Stop(); }

    private void PlayDriftBoostSound() { DriftBoost?.Play(); }
    private void StopDriftBoostSound(float _duration)
    {
        StartCoroutine(StopDriftBoostSoundAfterSeconds(_duration));
    }
    public IEnumerator StopDriftBoostSoundAfterSeconds(float _duration)
    {
        yield return new WaitForSecondsRealtime(_duration);
        DriftBoost?.Stop();
    }

    private void PlayJumpChargeSound() { JumpCharge?.Play(); }
    private void StopJumpChargeSound() { JumpCharge?.Stop(); }
    private void PlayJumpSound() { Jump?.Play(); StartCoroutine(StopJumpSound()); }
    private IEnumerator StopJumpSound()
    {
        yield return new WaitForSecondsRealtime(0.8f); //This is the duration of the Jump Sound
        Jump?.Stop();
    }
    private void PlayJumpChargedSound() { JumpCharged?.Play(); StartCoroutine(StopJumpChargedSound()); }
    private IEnumerator StopJumpChargedSound()
    {
        yield return new WaitForSecondsRealtime(1.0f);
        JumpCharged?.Stop();
    }

    private void PlayKickSound() { Kick?.Play(); }
    private void StopKickSound() { Kick?.Stop(); }
    private void PlayBladeModeOnSound() { BladeModeOn?.Play(); StartCoroutine(StopBladeModeOnSound()); }
    private IEnumerator StopBladeModeOnSound()
    {
        yield return new WaitForSecondsRealtime(0.5f);
        BladeModeOn?.Stop();
    }
    // private void StartBladeModeOffSound() { BladeModeOff?.Play(); StartCoroutine(StopBladeModeOffSound()); }
    // private IEnumerator StopBladeModeOffSound()
    // {
    //     yield return new WaitForSeconds(0.5f);
    //     BladeModeOff?.Stop();
    // }
    private void PlaySlashSound() { Slash?.Play(); }
    private void StopSlashSound() { Slash?.Stop(); }

    private void PlayHealthGainSound() { HealthGain?.Play(); StartCoroutine(StopHealthGainSound()); }
    private IEnumerator StopHealthGainSound()
    {
        yield return new WaitForSecondsRealtime(1.4f);
        HealthGain?.Stop();
    }

    private void PlayHurtSound() { if (Health.health > 0) TakeDamage?.Play(); StartCoroutine(StopHurtSound()); }
    private IEnumerator StopHurtSound()
    {
        yield return new WaitForSecondsRealtime(0.4f);
        TakeDamage?.Stop();
    }

    private void PlayDeathSound() { Death?.Play(); StartCoroutine(StopDeathSound()); }
    private IEnumerator StopDeathSound()
    {
        yield return new WaitForSecondsRealtime(1.3f);
        Death?.Stop();
    }

    private void PlayWallCollisionSound() { WallCollision?.Play(); }
    private void UpdateWallCollisionSound(Transform _collisionPoint)
    {
        WallCollisionObject.transform.position = _collisionPoint.position;
    }
    private void StopWallCollisionSound() { WallCollision?.Stop(); }

    private void PlayExplosionSound() { Explosion?.Play(); StartCoroutine(StopExplosionSound()); }
    private IEnumerator StopExplosionSound()
    {
        yield return new WaitForSecondsRealtime(2.0f);
        Explosion?.Stop();
    }

    private void PlayCheckpointSoud() { Checkpoint?.Play(); StartCoroutine(StopCheckpointSound()); }
    private IEnumerator StopCheckpointSound()
    {
        yield return new WaitForSecondsRealtime(2.65f);
        Checkpoint?.Stop();
    }
}