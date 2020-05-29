using UnityEngine;
using UnityEngine.AI;

public class NavMeshMoveTo : MonoBehaviour
{

    public Transform Player { get; set; }

    private NavMeshAgent agent;

    void Start()
    {
        agent = GetComponent<NavMeshAgent>();
    }

    void Update()
    {
        agent.destination = Player.position;
    }

#if UNITY_EDITOR
    private void OnDrawGizmos()
    {
        Gizmos.color = Color.magenta;
        Gizmos.DrawSphere( transform.position, 0.7f );
    }
#endif
}