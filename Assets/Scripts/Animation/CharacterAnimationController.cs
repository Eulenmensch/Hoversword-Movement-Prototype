using UnityEngine;

[RequireComponent( typeof( Animator ) )]
public class CharacterAnimationController : MonoBehaviour
{
    private Animator animator;

    private void OnEnable()
    {
        PlayerEvents.Instance.OnJump += StartJump;
        PlayerEvents.Instance.OnJumpCharge += StartJumpCharge;
        PlayerEvents.Instance.OnLand += StopJump;

        PlayerEvents.Instance.OnStartDashCharge += StartDash;
        PlayerEvents.Instance.OnStopDash += StopDash;
        PlayerEvents.Instance.OnStopDashCharge += CancelDash;

        PlayerEvents.Instance.OnStartKickAttack += KickAttack;

        PlayerEvents.Instance.OnStartAim += StartAim;
        PlayerEvents.Instance.OnStopAim += StopAim;
        PlayerEvents.Instance.OnStartSlashAttack += SlashAttack;
    }

    private void Start()
    {
        animator = GetComponent<Animator>();
    }

    void StartJump()
    {
        animator.SetTrigger( "StartJump" );
    }
    void StartJumpCharge()
    {
        animator.SetTrigger( "StartJumpCharge" );
    }
    void StopJump()
    {
        animator.SetTrigger( "StopJump" );
    }

    void StartDash()
    {
        animator.SetTrigger( "StartDash" );
        animator.SetBool( "Dashing", true );
    }

    void StopDash()
    {
        // animator.SetTrigger( "StopDash" );
        animator.SetBool( "Dashing", false );
    }

    void CancelDash()
    {
        if ( animator.GetCurrentAnimatorStateInfo( 0 ).IsName( "Boost Charge" ) )
        {
            animator.SetTrigger( "CancelDash" );
        }
    }

    void KickAttack()
    {
        animator.SetTrigger( "FlipAttack" );
    }

    void StartAim()
    {
        animator.SetTrigger( "StartAim" );
    }

    void StopAim()
    {
        animator.SetTrigger( "StopAim" );
    }

    void SlashAttack()
    {
        animator.SetTrigger( "SlashAttack" );
    }
}