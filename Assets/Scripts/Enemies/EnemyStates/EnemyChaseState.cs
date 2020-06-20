using UnityEngine;

public class EnemyChaseState : IEnemyState
{
    Enemy Owner;

    public EnemyChaseState(Enemy _owner)
    {
        this.Owner = _owner;
    }

    public void Enter()
    {
    }

    public void Execute()
    {
        float distanceToPlayer = Owner.GetDistanceToPlayer();
        if ( distanceToPlayer <= Owner.MeleeRange )
        {
            Owner.StateMachine.ChangeState( new EnemyMeleeState( Owner ) );
        }
        else if ( distanceToPlayer > Owner.ChaseRange )
        {
            Owner.StateMachine.ChangeState( new EnemyRangedState( Owner ) );
        }

        Owner.SetNavTarget( Owner.Player.transform );
    }

    public void Exit()
    {
    }
}