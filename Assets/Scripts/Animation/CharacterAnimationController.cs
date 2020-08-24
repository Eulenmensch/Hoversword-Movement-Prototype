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

        PlayerEvents.Instance.OnStartCarve += StartCarve;
        PlayerEvents.Instance.OnStopCarve += StopCarve;

        PlayerEvents.Instance.OnStartKickAttack += KickAttack;

        PlayerEvents.Instance.OnStartAim += StartAim;
        PlayerEvents.Instance.OnStopAim += StopAim;
        PlayerEvents.Instance.OnStartSlashAttack += SlashAttack;

        PlayerEvents.Instance.OnTakeDamage += TakeDamage;
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
        animator.SetBool( "DashCancel", false );
    }

    void StopDash()
    {
        animator.SetBool( "Dashing", false );
    }

    void CancelDash()
    {
        animator.SetBool( "DashCancel", true );
    }

    void StartCarve(float _direction)
    {
        string direction = "";
        if ( _direction > 0 )
        {
            direction = "Right";
        }
        else if ( _direction < 0 )
        {
            direction = "Left";
        }

        animator.SetTrigger( "StartDrift" + direction );
    }

    void StopCarve()
    {
        animator.SetTrigger( "StopDrift" );
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

    void TakeDamage()
    {
        animator.SetTrigger( "TakeDamage" );
    }
}