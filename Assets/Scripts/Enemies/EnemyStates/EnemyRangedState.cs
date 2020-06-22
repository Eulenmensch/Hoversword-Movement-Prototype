using UnityEngine;
using System.Collections;

public class EnemyRangedState : IEnemyState
{
    Enemy Owner;
    LineRenderer Line;

    bool CoroutineRunning;
    float AimTimer = 0.0f;
    float AimTime = 4.0f;
    float ShootPauseTimer = 0.0f;
    float ShootPauseTime = 1.5f;

    float DistanceToPlayer;

    public EnemyRangedState(Enemy _owner)
    {
        this.Owner = _owner;
    }

    public void Enter()
    {
        Line = Owner.GetComponent<LineRenderer>();
    }

    public void Execute()
    {
        DistanceToPlayer = Owner.GetDistanceToPlayer();
        ChangeMovementState( DistanceToPlayer );

        Owner.SetNavTarget( null ); //the navmeshtow script sets velocity to 0 when it has no target. This line makes the enemy stop in place.
        if ( !CoroutineRunning )
        {
            Owner.StartCoroutine( Aim() );
        }
    }

    public void Exit()
    {

    }

    IEnumerator Aim()
    {
        CoroutineRunning = true;
        Line.positionCount = 2;
        Line.widthMultiplier = 0.5f;
        while ( AimTimer <= AimTime )
        {
            Line.SetPosition( 0, new Vector3( 0, 8, 0 ) );
            Line.SetPosition( 1, Owner.transform.InverseTransformPoint( Owner.Player.transform.position ) );
            Line.widthMultiplier = Mathf.Lerp( Line.widthMultiplier, 2.0f, 0.01f );
            AimTimer += Time.deltaTime;
            yield return null;
        }
        AimTimer = 0.0f;
        Owner.StartCoroutine( Shoot() );
        Owner.StopCoroutine( Aim() );
    }

    IEnumerator Shoot()
    {
        GameObject.Instantiate( Owner.ProjectilePrefab, Owner.transform.position, Quaternion.LookRotation( Owner.Player.transform.position - Owner.transform.position ) );
        Line.widthMultiplier = 5.0f;
        while ( ShootPauseTimer <= ShootPauseTime )
        {
            Line.widthMultiplier = Mathf.Lerp( Line.widthMultiplier, 0, 0.2f );
            ShootPauseTimer += Time.deltaTime;
            yield return null;
        }
        Line.positionCount = 0;
        ShootPauseTimer = 0.0f;
        CoroutineRunning = false;
        Owner.StopCoroutine( Shoot() );
    }

    void ChangeMovementState(float _distanceToPlayer)
    {
        if ( _distanceToPlayer <= Owner.ChaseRange )
        {
            Owner.StateMachine.ChangeState( new EnemyChaseState( Owner ) );
        }
        else if ( _distanceToPlayer > Owner.RangedRange )
        {
            Owner.StateMachine.ChangeState( new EnemyIdleState( Owner ) );
        }
    }
}