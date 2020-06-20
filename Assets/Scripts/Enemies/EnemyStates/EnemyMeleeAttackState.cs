using UnityEngine;

public class EnemyMeleeState : IEnemyState
{
    Enemy Owner;

    public EnemyMeleeState(Enemy _owner)
    {
        this.Owner = _owner;
    }

    public void Enter()
    {
    }

    public void Execute()
    {
        float distanceToPlayer = Owner.GetDistanceToPlayer();
        if ( distanceToPlayer > Owner.MeleeRange )
        {
            Owner.StateMachine.ChangeState( new EnemyChaseState( Owner ) );
        }

        Owner.SetNavTarget( null );
    }

    public void Exit()
    {
    }
}