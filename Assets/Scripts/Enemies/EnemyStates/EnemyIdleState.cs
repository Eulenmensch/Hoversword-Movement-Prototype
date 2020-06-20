using UnityEngine;

public class EnemyIdleState : IEnemyState
{
    Enemy Owner;

    public EnemyIdleState(Enemy _owner)
    {
        this.Owner = _owner;
    }

    public void Enter()
    {
    }

    public void Execute()
    {
        if ( Owner.GetDistanceToPlayer() <= Owner.RangedRange )
        {
            Owner.StateMachine.ChangeState( new EnemyRangedState( Owner ) );
        }
        Owner.SetNavTarget( Owner.IdlePosition );
    }

    public void Exit()
    {
    }
}