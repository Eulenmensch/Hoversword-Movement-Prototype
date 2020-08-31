using System.Linq.Expressions;
using UnityEditor;
using UnityEngine;
using UnityEngine.InputSystem;

public class HoverBoardControllerMilan01 : MonoBehaviour
{
    public float HoverForce;
    public float AccellerationForce;
    public float TurnForce;
    public float TurnFriction;
    public float Drag;
    public float AngularDrag;
    public float RaycastLength;
    public Transform[] HoverPoints;
    public LayerMask GroundMask;
    public Transform CenterOfMass;
    public Transform Motor;
    public Transform TurnMotor;
    public float gravity;



    private Vector2 InputVector;
    private Rigidbody SwordRB;

    // Debugging
    [Header("Debugging")]
    public bool showDirections;
    public bool showGroundDistanceText;
    public GUIStyle DebugTextStyle;
    public bool showGroundDistanceRays;
    public Gradient DebugGradient;
    public bool showGroundForwardDirection;
    private Vector3 groundForwardDirection;
    public bool showTurnFrictionForce;
    private Vector3 turnFrictionForce;
    public bool showTurnTorque;
    private Vector3 turnTorque;

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
        foreach (var hoverPoint in HoverPoints)
        {
            if (Physics.Raycast(hoverPoint.position, -transform.up, out RaycastHit hit, RaycastLength, GroundMask))
            {
                // Apply Hover Force on Hover Points
                // RaycastLength - hit.distance => can be anything from 0 to raycastlenght... should really by mapped to 0-1
                // Why divide by Length again? -> So the multiplier is == Length when distance to ground == 0? But that isn't really helpful either...
                // I should really map this to a animationCurve
                SwordRB.AddForceAtPosition(transform.up * HoverForce * Mathf.Pow(RaycastLength - hit.distance, 2) / RaycastLength, hoverPoint.position, ForceMode.Acceleration);
            }
        }

        //makes the board take tighter turns with higher turn friction
        // transform.InverseTransformVector(SwordRB.velocity).x is greater or smaller than 0 according to movement direction
        turnFrictionForce = -transform.right * transform.InverseTransformVector(SwordRB.velocity).x * TurnFriction;
        SwordRB.AddForce(turnFrictionForce, ForceMode.Acceleration);
    }

    private void ApplyMoveInput()
    {
        //groundForwardDirection = new Vector3(transform.forward.x, 0.0f, transform.forward.z);

        if (Physics.Raycast(transform.position, -transform.up, out RaycastHit hit, RaycastLength, GroundMask))
        {
            groundForwardDirection = Vector3.Cross(hit.normal, -transform.right).normalized;
        }
        else //if (Physics.Raycast(transform.position, Vector3.down, out hit, Mathf.Infinity, GroundMask))//FIXME: Maybe just don't add velocity in the air?
        {
            groundForwardDirection = new Vector3(transform.forward.x, 0.0f, transform.forward.z);
            //groundForwardDirection = Vector3.Cross(hit.normal, -transform.right).normalized;
            //groundForwardDirection = Vector3.zero;
        }
        SwordRB.AddForceAtPosition(groundForwardDirection * AccellerationForce * InputVector.y, Motor.position, ForceMode.Acceleration);

        //turnTorque = transform.up * TurnForce * InputVector.x;
        //SwordRB.AddTorque(turnTorque, ForceMode.Acceleration);
        // turning by adding force very low tipping the character to the side and turning it
        turnTorque = -transform.right * TurnForce * Mathf.Pow(InputVector.x, 3);
        SwordRB.AddForceAtPosition(turnTorque, TurnMotor.position, ForceMode.Acceleration);

        // Apply gracity
        SwordRB.AddForce(-Vector3.up * gravity, ForceMode.Acceleration);
    }

    private void ApplyQuadraticDrag()
    {
        Vector3 drag = -Drag * SwordRB.velocity.normalized * SwordRB.velocity.sqrMagnitude;
        // drag.y = 0;
        SwordRB.AddForce(drag, ForceMode.Acceleration);
        SwordRB.AddTorque(-AngularDrag * SwordRB.angularVelocity.normalized * SwordRB.angularVelocity.sqrMagnitude, ForceMode.Acceleration);
    }

    public void GetMoveInput(InputAction.CallbackContext context)
    {
        InputVector = context.ReadValue<Vector2>();
    }

    private void OnDrawGizmos()
    {
        if (showGroundForwardDirection)
            Debug.DrawLine(transform.position, transform.position + groundForwardDirection * 2f, Color.red);
        if (showTurnFrictionForce)
            Debug.DrawLine(transform.position, transform.position + turnFrictionForce, Color.blue);
        if (showTurnTorque)
            Debug.DrawLine(transform.position, transform.position + turnTorque, Color.cyan);



        if (showGroundDistanceRays && HoverPoints.Length > 1)
        {
            foreach (var hoverPoint in HoverPoints)
            {
                Gizmos.DrawWireSphere(hoverPoint.position, 0.1f);

                RaycastHit hit;
                if (Physics.Raycast(hoverPoint.position, -transform.up, out hit, RaycastLength, GroundMask))
                {
                    Gizmos.color = DebugGradient.Evaluate(hit.distance / RaycastLength);
                    Gizmos.DrawSphere(hit.point, 0.07f);
                    Debug.DrawLine(hoverPoint.position, hoverPoint.position - transform.up * hit.distance, DebugGradient.Evaluate(hit.distance / RaycastLength));
                }
                Gizmos.color = Color.white;
            }
        }

        if (showDirections)
        {
            Debug.DrawRay(transform.position, -transform.up, Color.red);
            Debug.DrawRay(transform.position + transform.forward, transform.forward, Color.cyan);
        }
    }

#if UNITY_EDITOR
    private void OnGUI()
    {
        if (showGroundDistanceText)
        {
            foreach (var hoverPoint in HoverPoints)
            {
                RaycastHit hit;
                if (Physics.Raycast(hoverPoint.position, -transform.up, out hit, RaycastLength, GroundMask))
                {
                    string text = (hit.distance / RaycastLength).ToString("0.00"); //the ratio of intended height and actual height
                    Handles.Label(hoverPoint.position - transform.up * (hit.distance / 2), text, DebugTextStyle);
                }
            }
        }
    }
#endif
}
