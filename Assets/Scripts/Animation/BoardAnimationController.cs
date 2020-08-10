using UnityEngine;

[RequireComponent( typeof( Animator ) )]
public class BoardAnimationController : MonoBehaviour
{
    private Animator animator;

    private void OnEnable()
    {
        PlayerEvents.Instance.OnStartAim += StartAim;
        PlayerEvents.Instance.OnStopAim += StopAim;
        PlayerEvents.Instance.OnStartSlashAttack += StartSlashAttack;
        PlayerEvents.Instance.OnStopSlashAttack += StopSlashAttack;

        PlayerEvents.Instance.OnStartKickAttack += StartKickAttack;
        PlayerEvents.Instance.OnStopKickAttack += StopKickAttack;
    }

    private void Start()
    {
        animator = GetComponent<Animator>();
    }

    void StartAim()
    {
        animator.SetBool( "Aim", true );
    }

    void StopAim()
    {
        animator.SetBool( "Aim", false );
    }

    void StartKickAttack()
    {
        animator.SetBool( "Flip", true );
    }

    void StopKickAttack()
    {
        animator.SetBool( "Flip", false );
    }

    void StartSlashAttack()
    {
        animator.SetBool( "Slash", true );
    }

    void StopSlashAttack()
    {
        animator.SetBool( "Slash", false );
    }
}