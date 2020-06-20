using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Enemy : MonoBehaviour
{
    public float RangedRange;
    public float ChaseRange;
    public float MeleeRange;
    public float HitStunTime;


    public GameObject Player;
    public Transform IdlePosition;

    public EnemyStateMachine StateMachine = new EnemyStateMachine();

    private NavMeshTowBehaviour NavMeshTow;

    void Start()
    {
        print( "StateMachine Init" );
        StateMachine.ChangeState( new EnemyIdleState( this ) );
        print( "Idle State Init" );
        NavMeshTow = GetComponent<NavMeshTowBehaviour>();
    }

    void Update()
    {
        StateMachine.Update();
    }

    public float GetDistanceToPlayer()
    {
        return Vector3.Distance( transform.position, Player.transform.position );
    }

    public void SetNavTarget(Transform _target)
    {
        NavMeshTow.Target = _target;
    }
}
