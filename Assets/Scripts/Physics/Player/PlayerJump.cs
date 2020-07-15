using UnityEngine;
using System.Collections;

[RequireComponent( typeof( PlayerHandling ), typeof( Rigidbody ) )]
public class PlayerJump : MonoBehaviour
{
    [SerializeField] private float JumpForceMax;                //The maximum force JumpForce can be
    [SerializeField] private float JumpForceMin;                //The minimum force JumpForce can be
    [SerializeField] private float JumpChargeTime;              //The time in seconds it takes to charge up the jump while crouching
    [SerializeField] private float JumpForceChargeMin;          //The minumum factor the jump is scaled by when jumping with no charge  
    [SerializeField] private float CoyoteTime;                  //The time that a jump will still be possible after leaving the ground

    private PlayerHandling Handling;
    private Rigidbody RB;

    private float JumpForce;                //The impulse applied to the body upwards to make it jump
    private float JumpForceCharge;          //A value that goes up from 0 to 1 while crouching, impacting how much jump force will be exerted on the body
    private bool IsCharging;
    private bool IsGrounded;
    private bool IsCoyoteTimeRunning;

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
        if ( IsCharging && JumpForceCharge <= 1 )
        {
            JumpForceCharge += Time.deltaTime / JumpChargeTime;
        }
    }

    public void Jump()
    {
        if ( IsGrounded )
        {
            ScaleForceWithSpeed();
            Vector3 jumpForce = transform.up * JumpForce * JumpForceCharge;
            RB.AddForce( jumpForce, ForceMode.VelocityChange );
        }
    }

    private void ScaleForceWithSpeed()
    {
        JumpForce = JumpForceMin + ( ( JumpForceMax - JumpForceMin ) * ( RB.velocity.magnitude / Handling.MaxSpeed ) );
    }

    public void SetCharging(bool _charging)
    {
        IsCharging = _charging;
        JumpForceCharge = JumpForceChargeMin;
    }

    public void StartCoyoteTime()
    {
        if ( !IsCoyoteTimeRunning )
        {
            StartCoroutine( DoCoyoteTime() );
            IsCoyoteTimeRunning = true;
        }
    }

    private IEnumerator DoCoyoteTime()
    {
        yield return new WaitForSeconds( CoyoteTime );
        IsGrounded = false;
        IsCoyoteTimeRunning = false;
    }

    public void StopCoyoteTime()
    {
        StopCoroutine( DoCoyoteTime() );
        IsGrounded = true;
        IsCoyoteTimeRunning = false;
    }
}