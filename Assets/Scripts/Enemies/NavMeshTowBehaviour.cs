using System.Collections;
using UnityEngine;

public class NavMeshTowBehaviour : MonoBehaviour
{
    public GameObject TowBoat;
    public Transform Target; //FIXME: should this be public or only settable trough code?
    public float ForceMultiplier;
    [SerializeField] private Transform GroundCastOrigin;
    [SerializeField] private float FlickerTimer;
    [SerializeField] private LayerMask GroundMask;

    private Vector3 _nextCorner;
    private Vector3 PushDirection;
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
        Physics.Raycast( GroundCastOrigin.position, -transform.up, out hit, Mathf.Infinity, GroundMask );
        var towBoat = Instantiate( TowBoat, hit.point, Quaternion.identity );

        if ( towBoat.GetComponent<NavMeshMoveTo>().Target == null ) //FIXME: remove this if the target switching doesn't work. Maybe think this over anyways
        {
            towBoat.GetComponent<NavMeshMoveTo>().Target = Target;
        }

        yield return new WaitForSeconds( FlickerTimer );

        // if ( towBoat.GetComponent<UnityEngine.AI.NavMeshAgent>().path.corners.Length >= 2 )
        // {
        //     _nextCorner = towBoat.GetComponent<UnityEngine.AI.NavMeshAgent>().path.corners[1];
        // }

        Vector3 towBoatDirection = towBoat.GetComponent<UnityEngine.AI.NavMeshAgent>().velocity.normalized;
        PushDirection = towBoatDirection * ForceMultiplier;

        Destroy( towBoat );
        _coroutineRunning = false;
    }

    void PushTowardsCorner()
    {
        var dir = _nextCorner - transform.position;
        var normDir = dir.normalized;

        //RB.AddForce( normDir * ForceMultiplier, ForceMode.Acceleration );
        //RB.AddForce( PushDirection * ForceMultiplier, ForceMode.Acceleration );
        RB.velocity = new Vector3( PushDirection.x, RB.velocity.y, PushDirection.z );
    }
}