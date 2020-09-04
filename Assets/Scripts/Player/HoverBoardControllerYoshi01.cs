using System.Linq.Expressions;
using UnityEditor;
using UnityEngine;
using UnityEngine.InputSystem;

public class HoverBoardControllerYoshi01 : MonoBehaviour
{
    public float HoverForce;
    public float AccellerationForce;
    public float TurnForce;
    public float TurnFriction;
    public float Drag;
    public float AngularDrag;
    public float RaycastLength;
    public float GroundStickRayLength;
    public Transform[] HoverPoints;
    public LayerMask GroundMask;
    public Transform CenterOfMass;
    public Transform TurnMotor;
    public Transform Motor;
    public GUIStyle DebugTextStyle;
    public Gradient DebugGradient;

    private Vector2 InputVector;
    private Rigidbody SwordRB;

    private void Start()
    {
        SwordRB = GetComponent<Rigidbody>();
        SwordRB.centerOfMass = CenterOfMass.localPosition;
    }

    private void FixedUpdate()
    {
        Hover();
        ApplyMoveInput();
        ApplyQuadraticDrag();
    }

    private void Hover()
    {
        foreach ( var hoverPoint in HoverPoints )
        {
            RaycastHit hit;
            if ( Physics.Raycast( hoverPoint.position, -transform.up, out hit, RaycastLength, GroundMask ) )
            {
                SwordRB.AddForceAtPosition( transform.up * HoverForce * Mathf.Pow( RaycastLength - hit.distance, 2 ) / RaycastLength, hoverPoint.position, ForceMode.Acceleration );
            }
        }

        //makes the board take tighter turns with higher turn friction
        SwordRB.AddForce( -transform.right * transform.InverseTransformVector( SwordRB.velocity ).x * TurnFriction, ForceMode.Acceleration );
    }

    private void ApplyMoveInput()
    {
        RaycastHit hit;
        Vector3 groundForwardDirection = new Vector3( transform.forward.x, 0.0f, transform.forward.z );
        if ( Physics.Raycast( transform.position, -transform.up, out hit, GroundStickRayLength, GroundMask ) )
        {
            groundForwardDirection = Vector3.Cross( hit.normal, -transform.right ).normalized;
            Debug.DrawLine( transform.position, hit.point, Color.magenta );
        }
        else //if (Physics.Raycast(transform.position, Vector3.down, out hit, Mathf.Infinity, GroundMask))//FIXME: Maybe just don't add velocity in the air?
        {
            groundForwardDirection = new Vector3( transform.forward.x, 0.0f, transform.forward.z );
            //groundForwardDirection = Vector3.Cross(hit.normal, -transform.right).normalized;
            //groundForwardDirection = Vector3.zero;
        }
        SwordRB.AddForceAtPosition( groundForwardDirection * AccellerationForce * InputVector.y, Motor.position, ForceMode.Acceleration );

        //SwordRB.AddTorque(transform.up * TurnForce * InputVector.x, ForceMode.Acceleration);
        SwordRB.AddForceAtPosition( -transform.right * TurnForce * Mathf.Pow( InputVector.x, 3 ), TurnMotor.position, ForceMode.Acceleration );
    }

    private void ApplyQuadraticDrag()
    {
        SwordRB.AddForce( -Drag * SwordRB.velocity.normalized * SwordRB.velocity.sqrMagnitude, ForceMode.Acceleration );
        SwordRB.AddTorque( -AngularDrag * SwordRB.angularVelocity.normalized * SwordRB.angularVelocity.sqrMagnitude, ForceMode.Acceleration );
    }

    public void GetMoveInput(InputAction.CallbackContext context)
    {
        InputVector = context.ReadValue<Vector2>();
    }

    // private void OnDrawGizmos()
    // {
    //     if (HoverPoints.Length > 1)
    //     {
    //         foreach (var hoverPoint in HoverPoints)
    //         {
    //             Gizmos.DrawWireSphere(hoverPoint.position, 0.1f);

    //             RaycastHit hit;
    //             if (Physics.Raycast(hoverPoint.position, -transform.up, out hit, RaycastLength, GroundMask))
    //             {
    //                 Gizmos.color = DebugGradient.Evaluate(hit.distance / RaycastLength);
    //                 Gizmos.DrawSphere(hit.point, 0.07f);
    //                 Debug.DrawLine(hoverPoint.position, hoverPoint.position - transform.up * hit.distance, DebugGradient.Evaluate(hit.distance / RaycastLength));
    //             }
    //             Gizmos.color = Color.white;
    //         }
    //     }

    //     //Debug.DrawRay(transform.position, -transform.up, Color.red);
    //     Debug.DrawRay(transform.position, transform.TransformDirection(Vector3.forward), Color.cyan);
    // }

    // private void OnGUI()
    // {

    //     GUI.Label(new Rect(10, 10, 100, 20), "TurnInput: " + InputVector.x.ToString("0.00"));
    //     GUI.Label(new Rect(10, 40, 100, 20), "ThrustInput: " + InputVector.y.ToString("0.00"));
    //     foreach (var hoverPoint in HoverPoints)
    //     {
    //         RaycastHit hit;
    //         if (Physics.Raycast(hoverPoint.position, -transform.up, out hit, RaycastLength, GroundMask))
    //         {
    //             string text = (hit.distance / RaycastLength).ToString("0.00"); //the ratio of intended height and actual height
    //             Handles.Label(hoverPoint.position - transform.up * (hit.distance / 2), text, DebugTextStyle);
    //         }
    //     }
    // }
}
