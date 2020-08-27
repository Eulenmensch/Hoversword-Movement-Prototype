using UnityEngine;
using System.Collections;

[RequireComponent(typeof(PlayerHandling), typeof(Rigidbody))]
public class PlayerJump : MonoBehaviour
{
    public float JumpForceCharge { get; private set; }  //A value that goes up from 0 to 1 while crouching, impacting how much jump force will be exerted on the body

    [SerializeField] private float JumpForceMax;                //The maximum force JumpForce can be
    [SerializeField] private float JumpForceMin;                //The minimum force JumpForce can be
    [SerializeField] private float JumpChargeTime;              //The time in seconds it takes to charge up the jump while crouching
    [SerializeField] private float JumpForceChargeMin;          //The minumum factor the jump is scaled by when jumping with no charge  
    [SerializeField] private float CoyoteTime;                  //The time that a jump will still be possible after leaving the ground
    [SerializeField] private float LandingBufferTime;           //The time after which a landing is registered if a jump wasn't higher than groundcheck height

    private PlayerHandling Handling;
    private Rigidbody RB;

    private float JumpForce;                //The impulse applied to the body upwards to make it jump
    private bool IsCharging;
    private bool IsGrounded;
    private bool IsCoyoteTimeRunning;

    private Coroutine CoyoteTimeRoutine;
    private Coroutine LandingBufferRoutine;

    private void Start()
    {
        Handling = GetComponent<PlayerHandling>();
        RB = GetComponent<Rigidbody>();

        JumpForceCharge = JumpForceChargeMin;
    }

    private void Update()
    {
        ChargeJump();
    }

    private void ChargeJump()
    {
        if (IsCharging && JumpForceCharge <= 1)
        {
            JumpForceCharge += Time.deltaTime / JumpChargeTime;
        }
    }

    public void Jump()
    {
        if (IsGrounded)
        {
            ScaleForceWithSpeed();
            Vector3 jumpForce = transform.up * JumpForce * JumpForceCharge;
            RB.AddForce(jumpForce, ForceMode.VelocityChange);
        }
    }

    private void ScaleForceWithSpeed()
    {
        JumpForce = JumpForceMin + ((JumpForceMax - JumpForceMin) * (RB.velocity.magnitude / Handling.MaxSpeed));
    }

    public void SetCharging(bool _charging)
    {
        IsCharging = _charging;
        JumpForceCharge = JumpForceChargeMin;
    }

    public void StartCoyoteTime()
    {
        if (!IsCoyoteTimeRunning)
        {
            CoyoteTimeRoutine = StartCoroutine(DoCoyoteTime());
            IsCoyoteTimeRunning = true;
        }
    }

    private IEnumerator DoCoyoteTime()
    {
        yield return new WaitForSeconds(CoyoteTime);
        IsGrounded = false;
        IsCoyoteTimeRunning = false;
    }

    public void StopCoyoteTime()
    {
        StopCoroutine(CoyoteTimeRoutine);
        IsGrounded = true;
        IsCoyoteTimeRunning = false;
    }

    //fixes the rare occasion where a jump never makes the player register as not grounded which makes the animation
    //state machine get stuck in a falling state
    public void StartLandingBuffer()
    {
        LandingBufferRoutine = StartCoroutine(LandingBuffer());
    }

    private IEnumerator LandingBuffer()
    {
        yield return new WaitForSeconds(LandingBufferTime);
        if (Handling.IsGrounded)
        {
            PlayerEvents.Instance.JumpCancel();
            Handling.IsJumping = false;
        }
    }

    public void StopLandingBuffer()
    {
        if (LandingBufferRoutine != null)
        {
            StopCoroutine(LandingBufferRoutine);
        }
    }
}