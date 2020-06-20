using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class EnemyYoshi_01 : Enemy
{
    private void OnDrawGizmos()
    {
        Handles.color = Color.cyan;
        Handles.DrawWireDisc( transform.position, transform.up, RangedRange );
        Handles.color = Color.magenta;
        Handles.DrawWireDisc( transform.position, transform.up, ChaseRange );
        Handles.color = Color.green;
        Handles.DrawWireDisc( transform.position, transform.up, MeleeRange );
    }

    public void EnterGetHitState() //gets called by a unity event FIXME: proper C# event manager?
    {
        if ( !( StateMachine.CurrentState is EnemyGetHitState ) )
        {
            StateMachine.ChangeState( new EnemyGetHitState( this, StateMachine.CurrentState ) );
        }
    }
}
