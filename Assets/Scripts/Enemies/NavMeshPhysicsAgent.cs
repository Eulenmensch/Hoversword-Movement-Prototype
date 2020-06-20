using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class NavMeshPhysicsAgent : MonoBehaviour
{
    [SerializeField] float Speed;
    [SerializeField] GameObject Player;
    [SerializeField] bool Debugging;

    private Rigidbody RB;
    private NavMeshAgent Agent;
    private GroundCheck Grounded;

    private Transform NavTarget;
    private NavMeshPath Path;

    void Start()
    {
        RB = GetComponent<Rigidbody>();
        //Agent = GetComponent<NavMeshAgent>();
        Grounded = GetComponent<GroundCheck>();

        Path = new NavMeshPath();

        // Agent.updatePosition = false;
        // Agent.updateRotation = false;
        // Agent.updateUpAxis = false;

        NavTarget = Player.transform;
    }

    void Update()
    {
        CalculateNavPath();
        DebugPath();
    }

    private void FixedUpdate()
    {
        Move();
    }

    void Move()
    {
        Vector3 direction = ( Path.corners[1] - transform.position ).normalized * Speed;
        RB.velocity = new Vector3( direction.x, RB.velocity.y, direction.z );
    }

    void CalculateNavPath()
    {
        RaycastHit hit;
        Grounded.IsGrounded( out hit );
        NavMesh.CalculatePath( hit.point, NavTarget.position, NavMesh.AllAreas, Path );
    }

    void DebugPath()
    {
        if ( Debugging ) { return; }
        for ( int i = 0; i < Path.corners.Length - 1; i++ )
            Debug.DrawLine( Path.corners[i], Path.corners[i + 1], Color.red );
    }
}
