using UnityEngine;

public class EnemyRangedState : IEnemyState
{
    Enemy Owner;

    public EnemyRangedState(Enemy _owner)
    {
        this.Owner = _owner;
    }

    public void Enter()
    {
    }

    public void Execute()
    {
        float distanceToPlayer = Owner.GetDistanceToPlayer();
        if ( distanceToPlayer <= Owner.ChaseRange )
        {
            Owner.StateMachine.ChangeState( new EnemyChaseState( Owner ) );
        }
        else if ( distanceToPlayer > Owner.RangedRange )
        {
            Owner.StateMachine.ChangeState( new EnemyIdleState( Owner ) );
        }

        Owner.SetNavTarget( null ); //FIXME: maybe we need to return null here and perform a null check in the towbehaviour script
    }

    public void Exit()
    {
    }
}