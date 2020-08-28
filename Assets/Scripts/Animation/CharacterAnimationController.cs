using UnityEngine;

[RequireComponent(typeof(Animator))]
public class CharacterAnimationController : MonoBehaviour
{
    private Animator animator;

    private void OnEnable()
    {
        PlayerEvents.Instance.OnJump += StartJump;
        PlayerEvents.Instance.OnJumpCharge += StartJumpCharge;
        PlayerEvents.Instance.OnLand += StopJump;
        PlayerEvents.Instance.OnJumpCancel += CancelJump;
        PlayerEvents.Instance.OnHandleJumpAfterAim += HandleJumpAfterAim;

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
        animator.SetTrigger("StartJump");
        animator.SetBool("JumpCharging", false);
    }
    void StartJumpCharge()
    {
        animator.SetTrigger("StartJumpCharge");
        animator.SetBool("JumpCancel", false);
        animator.SetBool("Jumping", true);
        animator.SetBool("JumpCharging", true);
    }
    void StopJump()
    {
        animator.SetTrigger("StopJump");
        animator.SetBool("Jumping", false);
    }

    void CancelJump()
    {
        // animator.SetBool("Jumping", false);
        animator.SetBool("JumpCancel", true);
    }

    void HandleJumpAfterAim()
    {
        animator.SetBool("JumpCharging", false);
    }

    void StartDash()
    {
        animator.SetTrigger("StartDash");
        animator.SetBool("Dashing", true);
        animator.SetBool("DashCancel", false);
    }

    void StopDash()
    {
        animator.SetBool("Dashing", false);
    }

    void CancelDash()
    {
        animator.SetBool("DashCancel", true);
    }

    void StartCarve(float _direction)
    {
        string direction = "";
        if (_direction > 0)
        {
            direction = "Right";
            animator.SetBool("DriftingRight", true);
        }
        else if (_direction < 0)
        {
            direction = "Left";
            animator.SetBool("DriftingLeft", true);
        }

        animator.SetTrigger("StartDrift" + direction);
        animator.SetBool("Drifting", true);
        animator.SetFloat("DriftDirection", _direction);
    }

    void StopCarve()
    {
        animator.SetTrigger("StopDrift");
        animator.SetBool("DriftingRight", false);
        animator.SetBool("DriftingLeft", false);
        animator.SetBool("Drifting", false);
    }

    void KickAttack()
    {
        animator.SetTrigger("FlipAttack");
    }

    void StartAim()
    {
        animator.SetTrigger("StartAim");
        animator.SetBool("Aiming", true);
    }

    void StopAim()
    {
        animator.SetTrigger("StopAim");
        animator.SetBool("Aiming", false);
    }

    void SlashAttack()
    {
        animator.SetTrigger("SlashAttack");
    }

    void TakeDamage()
    {
        animator.SetTrigger("TakeDamage");
    }
}