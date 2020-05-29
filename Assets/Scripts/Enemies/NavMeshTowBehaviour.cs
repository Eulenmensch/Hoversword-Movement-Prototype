using System.Collections;
using UnityEngine;

public class NavMeshTowBehaviour : MonoBehaviour
{
    public GameObject TowBoat;
    public Transform Player;
    public float ForceMultiplier;
    [SerializeField] private float FlickerTimer;

    private Vector3 _nextCorner;
    private Rigidbody RB;
    private bool _coroutineRunning;
    private CustomCenterOfMass CenterOfMass;

    void Start()
    {
        RB = GetComponent<Rigidbody>();
        CenterOfMass = GetComponent<CustomCenterOfMass>();
    }

    void FixedUpdate()
    {
        if ( !_coroutineRunning )
        {
            StartCoroutine( IFlickerTowBoat() );
        }
        PushTowardsCorner();
    }

    IEnumerator IFlickerTowBoat()
    {
        _coroutineRunning = true;

        RaycastHit hit;
        Physics.Raycast( transform.position, -transform.up, out hit );
        var towBoat = Instantiate( TowBoat, hit.point, Quaternion.identity );

        if ( towBoat.GetComponent<NavMeshMoveTo>().Player == null )
        {
            towBoat.GetComponent<NavMeshMoveTo>().Player = Player;
        }

        yield return new WaitForSeconds( FlickerTimer );

        if ( towBoat.GetComponent<UnityEngine.AI.NavMeshAgent>().path.corners.Length >= 2 )
        {
            _nextCorner = towBoat.GetComponent<UnityEngine.AI.NavMeshAgent>().path.corners[1];
        }

        Destroy( towBoat );
        _coroutineRunning = false;
    }

    void PushTowardsCorner()
    {
        var dir = _nextCorner - transform.position;
        var normDir = dir.normalized;
        if ( Player != null )
        {
            RB.AddForce( normDir * ForceMultiplier, ForceMode.Acceleration );
        }
    }
}