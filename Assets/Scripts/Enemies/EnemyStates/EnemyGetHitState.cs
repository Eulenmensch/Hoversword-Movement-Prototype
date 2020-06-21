using UnityEngine;
using System.Collections;
using UnityEngine.Animations.Rigging;

public class EnemyGetHitState : IEnemyState
{
    Enemy Owner;
    IEnemyState LastState;
    NavMeshTowBehaviour NavMeshTow;

    bool HitStunEnded;

    public EnemyGetHitState(Enemy _owner, IEnemyState _lastState)
    {
        this.Owner = _owner;
        this.LastState = _lastState;
    }

    public void Enter()
    {
        NavMeshTow = Owner.GetComponent<NavMeshTowBehaviour>();
        NavMeshTow.enabled = false;
        HitStunEnded = false;
        Owner.StartCoroutine( HitStunTimer( Owner.HitStunTime ) );
    }

    public void Execute()
    {
        if ( HitStunEnded )
        {
            if ( Owner.gameObject.GetComponent<GroundCheck>().IsGrounded() )
            {
                if ( Owner.Health <= 0 )
                {
                    Owner.StateMachine.ChangeState( new EnemyDeathState( Owner ) );
                }
                else
                {
                    Owner.StateMachine.ChangeState( LastState );
                }
            }
        }
    }

    public void Exit()
    {
        NavMeshTow.enabled = true;
    }

    IEnumerator HitStunTimer(float _hitStunTime)
    {
        yield return new WaitForSeconds( _hitStunTime );
        HitStunEnded = true;
    }
}