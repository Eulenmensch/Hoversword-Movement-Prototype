using UnityEngine;
using UnityEngine.AI;

public class NavMeshMoveTo : MonoBehaviour
{

    public Transform Target { get; set; }

    private NavMeshAgent agent;

    void Start()
    {
        agent = GetComponent<NavMeshAgent>();
    }

    void Update()
    {
        if ( Target != null )
        {
            agent.destination = Target.position;
            if ( Vector3.Distance( transform.position, Target.position ) <= 0.5f ) //FIXME: Hardcoded balancing value
            {
                agent.velocity = Vector3.zero;
            }
        }
        else
        {
            agent.velocity = Vector3.zero;
        }
    }

#if UNITY_EDITOR
    private void OnDrawGizmos()
    {
        Gizmos.color = Color.magenta;
        Gizmos.DrawSphere( transform.position, 0.7f );
    }
#endif
}