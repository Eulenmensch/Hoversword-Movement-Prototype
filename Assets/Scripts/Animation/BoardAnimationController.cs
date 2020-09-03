using UnityEngine;

[RequireComponent(typeof(Animator))]
public class BoardAnimationController : MonoBehaviour
{
    private Animator animator;

    private void OnEnable()
    {
        PlayerEvents.Instance.OnJump += Jump;

        PlayerEvents.Instance.OnStartCarve += StartCarve;
        PlayerEvents.Instance.OnStopCarve += StopCarve;

        PlayerEvents.Instance.OnStartAim += StartAim;
        PlayerEvents.Instance.OnStopAim += StopAim;
        PlayerEvents.Instance.OnStartSlashAttack += StartSlashAttack;
        PlayerEvents.Instance.OnStopSlashAttack += StopSlashAttack;

        PlayerEvents.Instance.OnStartKickAttack += StartKickAttack;
        PlayerEvents.Instance.OnStopKickAttack += StopKickAttack;
    }

    private void OnDisable()
    {
        PlayerEvents.Instance.OnJump -= Jump;

        PlayerEvents.Instance.OnStartCarve -= StartCarve;
        PlayerEvents.Instance.OnStopCarve -= StopCarve;

        PlayerEvents.Instance.OnStartAim -= StartAim;
        PlayerEvents.Instance.OnStopAim -= StopAim;
        PlayerEvents.Instance.OnStartSlashAttack -= StartSlashAttack;
        PlayerEvents.Instance.OnStopSlashAttack -= StopSlashAttack;

        PlayerEvents.Instance.OnStartKickAttack -= StartKickAttack;
        PlayerEvents.Instance.OnStopKickAttack -= StopKickAttack;
    }

    private void Start()
    {
        animator = GetComponent<Animator>();
    }

    void Jump()
    {
        animator.SetTrigger("Jump");
    }

    void StartCarve(float _direction)
    {
        string direction = "";
        if (_direction > 0)
        {
            direction = "Right";
        }
        else if (_direction < 0)
        {
            direction = "Left";
        }

        animator.SetTrigger("StartDrift" + direction);
        animator.SetBool("Drifting", true);
        animator.SetFloat("DriftDirection", _direction);
    }

    void StopCarve()
    {
        animator.SetTrigger("StopDrift");
        animator.SetBool("Drifting", false);
    }

    void StartAim()
    {
        animator.SetBool("Aim", true);
        animator.SetTrigger("StartAim");
    }

    void StopAim()
    {
        animator.SetBool("Aim", false);
    }

    void StartKickAttack()
    {
        animator.SetBool("Flip", true);
    }

    void StopKickAttack()
    {
        animator.SetBool("Flip", false);
    }

    void StartSlashAttack()
    {
        animator.SetBool("Slash", true);
    }

    void StopSlashAttack()
    {
        animator.SetBool("Slash", false);
    }
}