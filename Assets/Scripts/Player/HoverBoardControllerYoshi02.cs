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
    //public float AnticipativeHoverForce;    //The force that smoothes out sudden changes in ground gradient
    public float HoverHeight;               //The ideal height at which the board wants to hover
    //public float GroundStickForce;          //The force applied inverse to ground normal
    public float GroundStickHeight;         //The maximum height at which the acceleration force direction is projected on the ground and ground stick force is applied
    public Transform[] HoverPoints;         //The points from which ground distance is measured and where hover force is applied

    [Header( "PID Controller Settings" )]
    [Range( 0.0f, 1.0f )] public float ProportionalGain;  //A tuning value for the proportional error correction
    [Range( 0.0f, 1.0f )] public float IntegralGain;      //A tuning value for the integral error correction
    [Range( 0.0f, 1.0f )] public float DerivativeGain;    //A tuning value for the derivative error correction

    [Header( "Handling Settings" )]
    [SerializeField] private GroundThrustModes GroundThrustMode;    //Dropdown to switch between thrust modes on the ground
    public float GroundAccelerationForce;                           //The force that accelerates the board in its forward direction, projected on the ground
    public float TurnForce;                                         //The force that makes the board turn
    public float SidewaysFriction;                                  //The force that keeps the board from sliding sideways
    //[MinMaxSlider( -1, 1 )] public Vector2 ThrustMotorYFineTuning;     //Fine tuning for the thrust motor local y position
    //[MinMaxSlider( 0, 1 )] public Vector2 TurnMotorZFineTuning;        //Fine tuning for the turn motor local z position

    [Header( "Aerial Handling Settings" )]
    [SerializeField] private AirThrustModes AirThrustMode;     //Dropdown to switch between thrust modes in the air
    [SerializeField] private float AirAccelerationForce;        //The force that accelerates the board in the air 
    [SerializeField] private float JumpForce;                   //The impulse applied to the body upwards to make it jump
    [SerializeField] private float StabilizationForce;          //The force exerted on the body to orient it upright
    [SerializeField] private float StabilizationSpeed;          //The time it takes for the board to return to an upright state
    [SerializeField] private float AirControlForce;             //The angular force exerted on the body by player input
    [SerializeField] private AirControlModes PitchControlMode;  //Should the rotation around the sidewards axis be stabilized?
    [SerializeField] private AirControlModes RollControlMode;   //Should the rotation around the forward axis be stabilized?


    [Header( "Physics Settings" )]
    public float Drag;                      //Quadratic force applied counter the board's velocity
    public float AngularDrag;               //Quadratic force applied counter the board's angular velocity
    public float GroundGravity;             //The gravity applied when 'grounded'
    public float AirGravity;                //The gravity applied when 'airborne'

    [Header( "Camera Settings" )]
    //[MinMaxSlider( 0, 1 )] public Vector2 CameraLookAtZOffset;    //The offset of the camera look at which influences how much the camera leans into turns
    //[MinMaxSlider( 0, 1 )] public Vector2Int FOV;                 //The Camera's FOV

    [Header( "General Settings" )]
    [SerializeField] private LayerMask GroundMask;      //The layer mask that determines what counts as ground
    [SerializeField] private Transform CenterOfMass;    //The location where the boards center of mass is shifted. This keeps the board from tipping over
    [SerializeField] private Transform ThrustMotor;     //The location where acceleration force is applied
    [SerializeField] private Transform TurnMotor;       //The location where turn force is applied
    [SerializeField] private Animator CharacterAnimator;//FIXME: This is definitely not the responsibility of this class


    private enum GroundThrustModes { Manual, Automatic }    //An enum for switching between types of thrust handling on the ground
    private enum AirThrustModes { Manual, NoThrust, RetainGroundDirection } //An enum for switching between types of thrust handling in the air
    private enum AirControlModes { Manual, Stabilized }     //An enum for switching between types of rotational correction in the air

    //References
    private Rigidbody RB;                   //A reference to the board's rigidbody
    private PIDController[] PIDs;           //References to the PIDController class that handles error correction and smoothens out the hovering

    //Physics fields
    private float MaxSpeed;                 //The maximum velocity the board can have on a flat surface given the defined parameters
    private Vector3 ThrustDirection;        //The direction thrust is applied to the rigidbody. I'm caching this value as a field for aerial movement

    //Input fields
    private float ThrustInput;              //The amount of thrust input set in the SetMoveInput method
    private float TurnInput;                //The amount of thrust input set in the SetMoveInput method
    private float PitchInput;               //The amount of pitch input set in the Set AirControlInput method
    private float RollInput;                //The amount of roll input set in the Set AirControlInput method

    //Stupid fields FIXME:
    private bool IsCrouching;


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
        MaxSpeed = Mathf.Sqrt( GroundAccelerationForce / Drag ) * 10;   //TODO: this will later be in Start() when done tuning

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
        Thrust();               //TODO: Integrate in the Handling method once cleaned up
        Handling();
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
                //Grapher.Log( forcePercent, "PID" + Array.IndexOf( HoverPoints, hoverPoint ).ToString() );   //plots the PID value in an editor toolTODO: remove when done tuning 

                //calculate the adjusted force in the direction of the ground normal
                Vector3 adjustedForce = HoverForce * forcePercent * groundNormal;

                //Add the force to the rigidbody at the respective hoverpoint's position
                RB.AddForceAtPosition( adjustedForce, hoverPoint.position, ForceMode.Acceleration );
            }
        }
    }

    private void Handling()
    {
        if ( IsGrounded() )
        {
            //Thrust(); //FIXME: The thrust methods currently have code for grounded and aerial stuff that should be seperated first
            Turn();
            ApplySidewaysFriction();    //FIXME: Not sure if this should also run in the air
        }
        else
        {
            AirControl();
        }
    }
    private void Thrust()
    {
        if ( IsGrounded() )
        {
            //Handle grounded thrust
            if ( GroundThrustMode == GroundThrustModes.Manual )
            {
                //Add thrust to the body multiplying the force with thrust input
                GroundThrust( ThrustInput );
            }
            else if ( GroundThrustMode == GroundThrustModes.Automatic )
            {
                //Add thrust to the body multiplying the force by one (not modifying it)
                GroundThrust( 1.0f );
            }
        }

        else if ( !IsGrounded() )
        {
            //Handle aerial thrust
            if ( AirThrustMode == AirThrustModes.Manual )
            {
                //project the boards forward direction on world xz-plane
                Vector3 thrustDirection = Vector3.ProjectOnPlane( transform.forward, Vector3.up );

                //Add thrust to the body in its projected forward direction multiplying the force with thrust input
                AirThrust( ThrustInput, transform.forward );
            }
            else if ( AirThrustMode == AirThrustModes.NoThrust )
            {
                //Add no thrust to the body
                AirThrust( 0.0f, Vector3.zero );
            }
            else if ( AirThrustMode == AirThrustModes.RetainGroundDirection )
            {
                //Add thrust to the body in its thrust direction before it left the ground multiplying the force with thrust input
                AirThrust( ThrustInput, ThrustDirection );
            }
        }
    }

    private void GroundThrust(float _thrustInput)
    {
        RaycastHit hit;

        //Shoot a ray down to get the hit ground normal
        IsGrounded( out hit );

        //Project the board's forward direction onto the ground
        Vector3 groundForward = Vector3.ProjectOnPlane( transform.forward, hit.normal );

        //Set the direction thrust is applied in to the ground projected direction
        ThrustDirection = groundForward;

        //Calculate thrust force
        Vector3 thrustForce = ThrustDirection * GroundAccelerationForce * _thrustInput;
        //Apply calculated thrust to the rigidbody at the thrust motor position
        RB.AddForceAtPosition( thrustForce, ThrustMotor.position, ForceMode.Acceleration );
    }

    private void AirThrust(float _thrustInput, Vector3 _thrustDirection)
    {
        Vector3 thrustDirection = _thrustDirection;

        //Calculate thrust force
        Vector3 thrustForce = thrustDirection * AirAccelerationForce * _thrustInput;
        //Apply calculated thrust to the rigidbody at its center of mass
        RB.AddForce( thrustForce, ForceMode.Acceleration );
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

    private void AirControl()
    {
        //Define the axis we use for pitch rotation
        Vector3 pitchAxis = transform.right;
        //Define the axis we use for roll rotation
        Vector3 rollAxis = transform.forward;
        //Define the up rotation the body is rotated to
        Vector3 upDirection = Vector3.up;

        if ( PitchControlMode == AirControlModes.Stabilized ) { StabilizeAngularMotion( pitchAxis, upDirection ); }
        if ( PitchControlMode == AirControlModes.Manual ) { ControlAngularMotion( pitchAxis, PitchInput ); }
        //FIXME: the turn method call is way too hacky, we need clean seperation of aerial and grounded turning but ok for prototyping
        if ( RollControlMode == AirControlModes.Stabilized ) { StabilizeAngularMotion( rollAxis, upDirection ); Turn(); } //FIXME:
        if ( RollControlMode == AirControlModes.Manual ) { ControlAngularMotion( -rollAxis, RollInput ); }
    }

    //Is called by a unity event set in the inspector. Super evil! FIXME: refactor this out of existence
    public void Jump()
    {
        if ( !IsCrouching )
        {
            IsCrouching = true;
            CharacterAnimator.SetBool( "IsCrouching", true );
        }
        else if ( IsCrouching )
        {
            IsCrouching = false;
            CharacterAnimator.SetBool( "IsCrouching", false );
            if ( IsGrounded() )
            {
                RB.AddForce( Vector3.up * JumpForce, ForceMode.VelocityChange );
            }
        }
    }
    //Adds torque to the rigidbody to make it return to a upright position.
    //Takes an axis to rotate around as well as the up direction as arguments
    private void StabilizeAngularMotion(Vector3 _rotationAxis, Vector3 _upDirection)
    {
        //Do some spooky voodoo shit http://answers.unity.com/answers/10426/view.html
        float predictedUpAngle = RB.angularVelocity.magnitude * Mathf.Rad2Deg * StabilizationForce / StabilizationSpeed;
        //Calculate the necessary rotation
        Vector3 predictedUp = Quaternion.AngleAxis( predictedUpAngle, RB.angularVelocity ) * transform.up;
        //Do we need to rotate cw or ccw? In which plane?
        Vector3 torqueVector = Vector3.Cross( predictedUp, _upDirection );
        //Only affect the axis given by the attribute
        torqueVector = Vector3.Project( torqueVector, _rotationAxis );

        //Add the torque force to the body
        RB.AddTorque( torqueVector * StabilizationSpeed * StabilizationSpeed, ForceMode.Acceleration );
    }

    //Adds torque to the rigidbody based on the player Input
    private void ControlAngularMotion(Vector3 _rotationAxis, float _controlInput)
    {
        Vector3 controlForce = _rotationAxis * AirControlForce * _controlInput;
        RB.AddTorque( controlForce, ForceMode.Acceleration );
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
    public void SetMoveInput(float _thrust, float _turn)
    {
        ThrustInput = _thrust;
        TurnInput = _turn;
    }
    public void SetAirControlInput(float _pitch, float _roll)
    {
        PitchInput = _pitch;
        RollInput = _roll;
    }
}
