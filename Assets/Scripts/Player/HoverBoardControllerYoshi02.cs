//controls the hoverboard making heavy use of the physics engine
//this script is set up for balancing. I put a TODO: marker for performance impacting lines that are only for balancing.
//Note: When I talk about the board being 'grounded', I mean the height range in which I consider the board to not be flying/aerial

using System;
using UnityEngine;
using MinMaxSlider;

public class HoverBoardControllerYoshi02 : MonoBehaviour
{
    [Header( "Hover Settings" )]
    public float HoverForce;                //The force that pushes the board upwards
    public float AnticipativeHoverForce;    //The force that smoothes out sudden changes in ground gradient
    public float HoverHeight;               //The ideal height at which the board wants to hover
    public float GroundStickForce;          //The force applied inverse to ground normal
    public float GroundStickHeight;         //The maximum height at which the acceleration force direction is projected on the ground and ground stick force is applied
    public Transform[] HoverPoints;         //The points from which ground distance is measured and where hover force is applied

    [Header( "PID Controller Settings" )]
    [Range( 0.0f, 1.0f )] public float ProportionalGain;  //A tuning value for the proportional error correction
    [Range( 0.0f, 1.0f )] public float IntegralGain;      //A tuning value for the integral error correction
    [Range( 0.0f, 1.0f )] public float DerivativeGain;    //A tuning value for the derivative error correction

    [Header( "Handling Settings" )]
    public ThrustModes ThrustMode;          //Dropdown to switch between thrust modes
    public float AccelerationForce;         //The force that accelerates the board in its forward direction, projected on the ground
    public float TurnForce;                 //The force that makes the board turn
    public float SidewaysFriction;              //The force that keeps the board from sliding sideways
    [MinMaxSlider( -1, 1 )] public Vector2 ThrustMotorYFineTuning;     //Fine tuning for the thrust motor local y position
    [MinMaxSlider( 0, 1 )] public Vector2 TurnMotorZFineTuning;        //Fine tuning for the turn motor local z position

    [Header( "Physics Settings" )]
    public float Drag;                      //Quadratic force applied counter the board's velocity
    public float AngularDrag;               //Quadratic force applied counter the board's angular velocity
    public float GroundGravity;             //The gravity applied when 'grounded'
    public float AirGravity;                //The gravity applied when 'airborne'

    [Header( "Camera Settings" )]
    [MinMaxSlider( 0, 1 )] public Vector2 CameraLookAtZOffset;    //The offset of the camera look at which influences how much the camera leans into turns
    [MinMaxSlider( 0, 1 )] public Vector2Int FOV;                 //The Camera's FOV

    [Header( "General Settings" )]
    [SerializeField] private LayerMask GroundMask;      //The layer mask that determines what counts as ground
    [SerializeField] private Transform CenterOfMass;    //The location where the boards center of mass is shifted. This keeps the board from tipping over
    [SerializeField] private Transform ThrustMotor;     //The location where acceleration force is applied
    [SerializeField] private Transform TurnMotor;       //The location where turn force is applied


    public enum ThrustModes { Manual, Automatic }   //An enum for switching between types of input handling
    private Rigidbody RB;                   //A reference to the board's rigidbody
    private PIDController[] PIDs;           //References to the PIDController class that handles error correction and smoothens out the hovering

    private float MaxSpeed;                 //The maximum velocity the board can have on a flat surface given the defined parameters
    private Vector3 ThrustDirection;        //The direction thrust is applied to the rigidbody. I'm caching this value as a field for aerial movement

    private float ThrustInput;              //The amount of thrust input set in the SetInput method
    private float TurnInput;                //The amount of thrust input set in the SetInput method

    private void Start()
    {
        RB = GetComponent<Rigidbody>();
        RB.centerOfMass = CenterOfMass.localPosition;

        //Create an instance of the PIDController class for each hover point
        PIDs = new PIDController[HoverPoints.Length];
        for ( int i = 0; i < HoverPoints.Length; i++ )
        {
            PIDs[i] = new PIDController( ProportionalGain, IntegralGain, DerivativeGain );
        }
    }

    private void Update()
    {
        //Calculate the maximum velocity based on the defined acceleration force and drag
        MaxSpeed = Mathf.Sqrt( AccelerationForce / Drag ) * 10;   //TODO: this will later be in Start() when done tuning

        //update the gains of each PID controller TODO: this will be removed when done tuning
        foreach ( PIDController pid in PIDs )
        {
            pid.Kp = ProportionalGain;
            pid.Ki = IntegralGain;
            pid.Kd = DerivativeGain;
        }
    }

    private void FixedUpdate()
    {
        SetGravity();
        Hover();
        Thrust();
        Turn();
        ApplySidewaysFriction();
        ApplyQuadraticDrag();
    }

    private void Hover()
    {
        foreach ( Transform hoverPoint in HoverPoints )
        {
            //The ray used at each hover point down from the board
            Ray hoverRay = new Ray( hoverPoint.position, -transform.up );
            RaycastHit hit;

            if ( Physics.Raycast( hoverRay, out hit, HoverHeight, GroundMask ) )
            {
                float actualHeight = hit.distance;
                Vector3 groundNormal = hit.normal;

                //Use the respective PID controller to calculate the percentage of hover force to be used
                float forcePercent = PIDs[Array.IndexOf( HoverPoints, hoverPoint )].Control( HoverHeight, actualHeight );

                //calculate the adjusted force in the direction of the ground normal
                Vector3 adjustedForce = HoverForce * forcePercent * groundNormal;

                //Add the force to the rigidbody at the respective hoverpoint's position
                RB.AddForceAtPosition( adjustedForce, hoverPoint.position, ForceMode.Acceleration );
            }
        }
    }

    private void Thrust()
    {
        if ( ThrustMode == ThrustModes.Manual )
        {
            ThrustManual();
        }
        else if ( ThrustMode == ThrustModes.Automatic )
        {
            ThrustAutomatic();
        }
    }
    private void ThrustManual()
    {
        RaycastHit hit;

        //If the board is 'grounded'
        if ( IsGrounded( out hit ) )
        {
            //Project the board's forward direction onto the ground
            Vector3 groundForward = Vector3.ProjectOnPlane( transform.forward, hit.normal );

            //Set the direction thrust is applied in to the ground projected direction
            ThrustDirection = groundForward;
        }

        //Calculate thrust force
        Vector3 thrustForce = ThrustDirection * AccelerationForce * ThrustInput;
        //Apply calculated thrust to the rigidbody at the thrust motor position
        RB.AddForceAtPosition( thrustForce, ThrustMotor.position, ForceMode.Acceleration );
    }

    private void ThrustAutomatic()
    {

    }

    private void Turn()
    {
        //Make the Turn Input scale exponentially to get more of a carving feel when steering
        float scaledTurnInput = Mathf.Pow( TurnInput, 3 );
        //Calculate turn force
        Vector3 turnForce = -transform.right * TurnForce * scaledTurnInput;
        //Apply calculated turn force to the rigidbody at the turn motor position
        RB.AddForceAtPosition( turnForce, TurnMotor.position, ForceMode.Acceleration );
    }

    private void ApplySidewaysFriction()
    {
        float sidewaysSpeed = Vector3.Dot( RB.velocity, -transform.right );
        RB.AddForce( transform.right * sidewaysSpeed * SidewaysFriction, ForceMode.Acceleration );
    }

    private void ApplyQuadraticDrag()
    {
        //Apply translational drag
        RB.AddForce( -Drag * RB.velocity.normalized * RB.velocity.sqrMagnitude, ForceMode.Acceleration );
        //Apply rotational drag
        RB.AddTorque( -AngularDrag * RB.angularVelocity.normalized * RB.angularVelocity.sqrMagnitude, ForceMode.Acceleration );
    }

    private void SetGravity() //TODO: If there are ever more physics objects in the scene, board gravity might need to be applied manually
    {
        //While the board is 'grounded'
        if ( IsGrounded() )
        {
            //Set the gravity to the defined ground gravity
            Physics.gravity = new Vector3( 0, -GroundGravity, 0 );
        }
        //While the board is 'airborne'
        else
        {
            //Set the gravity to the defined air gravity
            Physics.gravity = new Vector3( 0, -AirGravity, 0 );
        }
    }

    //Checks downwards for Ground TODO: maybe using Vector3.down and a custom ground check ray length would give cleaner
    //                                  results? E.g. this version would return true when driving on a wall
    private bool IsGrounded()
    {
        return ( Physics.Raycast( transform.position, -transform.up, GroundStickHeight, GroundMask ) );
    }
    //overloaded function that also gives raycast hit info in an out parameter
    private bool IsGrounded(out RaycastHit _hit)
    {
        RaycastHit hit;
        bool ray = Physics.Raycast( transform.position, -transform.up, out hit, GroundStickHeight, GroundMask );
        _hit = hit;
        return ray;
    }

    //Sets the thrust and turn input
    public void SetInput(float _thrust, float _turn)
    {
        ThrustInput = _thrust;
        TurnInput = _turn;
    }
}
