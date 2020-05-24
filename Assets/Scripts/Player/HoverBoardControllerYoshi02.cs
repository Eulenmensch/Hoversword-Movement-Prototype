//controls the hoverboard making heavy use of the physics engine
//this script is set up for balancing. I put a TODO: marker for performance impacting lines that are only for balancing.
//Note: When I talk about the board being 'grounded', I mean the height range in which I consider the board to not be flying/aerial

using System;
using System.Collections;
using UnityEngine;
using UnityEngine.Events;
//using MinMaxSlider;

public class HoverBoardControllerYoshi02 : MonoBehaviour
{
    #region Settings
    [Header( "Hover Settings" )]
    public float HoverForce;                //The force that pushes the board upwards
    //public float AnticipativeHoverForce;    //The force that smoothes out sudden changes in ground gradient
    public float HoverHeight;               //The ideal height at which the board wants to hover
    public float GroundStickForce;          //The force applied inverse to ground normal
    [SerializeField] private bool StickToGround;    //Whether the board should stick to the ground when grounded
    public float GroundStickHeight;         //The maximum height at which the acceleration force direction is projected on the ground and ground stick force is applied
    //public Transform[] HoverPoints;         //The transforms from which ground distance is measured and where hover force is applied
    [SerializeField] GameObject HoverPointPrefab;             //The hover point prefab
    [SerializeField] GameObject HoverPointContainer;
    [SerializeField] private GameObject[] HoverPoints;     //The points from which ground distance is measured and where hover force is applied
    [SerializeField] private BoxCollider HoverArea;  //The area in which a hoverpoint array is generated
    [SerializeField] private int HoverPointRows;  //how many hoverpoint rows are generated
    [SerializeField] private int HoverPointColumns;   //how many hoverpoint columns are generated

    [Header( "PID Controller Settings" )]
    [Range( 0.0f, 1.0f )] public float ProportionalGain;  //A tuning value for the proportional error correction
    [Range( 0.0f, 1.0f )] public float IntegralGain;      //A tuning value for the integral error correction
    [Range( 0.0f, 1.0f )] public float DerivativeGain;    //A tuning value for the derivative error correction

    [Header( "Handling Settings" )]
    [SerializeField] private GroundThrustModes GroundThrustMode;    //Dropdown to switch between thrust modes on the ground
    public float GroundAccelerationForce;                           //The force that accelerates the board in its forward direction, projected on the ground
    [SerializeField] private float TurnForceMax;                    //The maximum force TurnForce can be
    [SerializeField] float TurnForceMin;                            //The minimum force TurnForce can be
    public float CarveForce;                                        //The additional force that makes the board carve
    [SerializeField] private float BoostForce;                      //The additional force applied to the body while boosting
    public float SidewaysFriction;                                  //The force that keeps the board from sliding sideways
    public float CarveFriction;                                     //The additional force that keeps the board from sliding sideways during a carve
    [SerializeField] private float SideShiftForce;                  //The force that makes the body shift left and right
    public float IdleFriction;                                      //The force that keeps the board from sliding when idle
    public float IdleSpeed;                                         //The velocity at which the body is considered idle
    //[MinMaxSlider( -1, 1 )] public Vector2 ThrustMotorYFineTuning;     //Fine tuning for the thrust motor local y position
    //[MinMaxSlider( 0, 1 )] public Vector2 TurnMotorZFineTuning;        //Fine tuning for the turn motor local z position

    [Header( "Aerial Handling Settings" )]
    [SerializeField] private AirThrustModes AirThrustMode;      //Dropdown to switch between thrust modes in the air
    [SerializeField] private float AirAccelerationForce;        //The force that accelerates the board in the air 
    [SerializeField] private float JumpForceMax;                //The maximum force JumpForce can be
    [SerializeField] private float JumpForceMin;                //The minimum force JumpForce can be
    [SerializeField] private float JumpChargeTime;              //The time in seconds it takes to charge up the jump while crouching
    [SerializeField] private float JumpForceChargeMin;          //The minumum factor the jump is scaled by when jumping with no charge    
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
    [SerializeField] private LayerMask GroundMask;          //The layer mask that determines what counts as ground
    [SerializeField] private Transform CenterOfMass;        //The location where the boards center of mass is shifted. This keeps the board from tipping over
    [SerializeField] private Transform ThrustMotor;         //The location where acceleration force is applied
    [SerializeField] private Transform TurnMotor;           //The location where turn force is applied
    [SerializeField] private Transform CarveMotor;          //The location where carve force is applied
    [SerializeField] private Transform SideShiftMotor;      //The location where side shift force is applied 
    [SerializeField] private Transform CoyoteTime;  //The location from where the jump ground check is performed
    [SerializeField] private Animator CharacterAnimator;    //FIXME: This is definitely not the responsibility of this class
    #endregion

    #region Events
    [SerializeField] private UnityEvent OnJump;//FIXME: This makes me want to make a proper event system
    #endregion

    #region Enums
    private enum GroundThrustModes { Manual, Automatic }    //An enum for switching between types of thrust handling on the ground
    private enum AirThrustModes { Manual, NoThrust, RetainGroundDirection } //An enum for switching between types of thrust handling in the air
    private enum AirControlModes { Manual, Stabilized }     //An enum for switching between types of rotational correction in the air
    #endregion

    #region Fields
    //References
    private Rigidbody RB;                   //A reference to the board's rigidbody
    private PIDController[] PIDs;           //References to the PIDController class that handles error correction and smoothens out the hovering

    //Physics fields
    [HideInInspector]
    public float MaxSpeed;                 //The maximum velocity the board can have on a flat surface given the defined parameters
    private Vector3 ThrustDirection;        //The direction thrust is applied to the rigidbody. I'm caching this value as a field for aerial movement
    private float TurnForce;                //The force that makes the board turn
    private float JumpForce;                //The impulse applied to the body upwards to make it jump
    [HideInInspector]
    public float JumpForceCharge;           //A value that goes up from 0 to 1 while crouching, impacting how much jump force will be exerted on the body

    //Input fields
    private float ThrustInput;              //The amount of thrust input set in the SetMoveInput method
    private float TurnInput;                //The amount of thrust input set in the SetMoveInput method
    private float PitchInput;               //The amount of pitch input set in the SetAirControlInput method
    private float RollInput;                //The amount of roll input set in the SetAirControlInput method
    private bool IsGettingCarveInput;       //Whether the carve input is being triggered. Set in the SetCarveInput method

    //Stupid fields FIXME:
    private bool IsCrouching;
    private bool IsDashing;
    #endregion

    private void Start()
    {
        JumpForceCharge = JumpForceChargeMin;

        HoverPoints = new GameObject[HoverPointRows * HoverPointColumns];
        GenerateHoverPoints( HoverArea, HoverPointColumns, HoverPointRows );

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
        CalculateMaxSpeed();
        SetGravity();
        Hover();
        Thrust();               //TODO: Integrate in the Handling method once cleaned up
        Handling();
        Moves();
        ApplyQuadraticDrag();
    }

    #region Hovering
    private void GenerateHoverPoints(BoxCollider _area, int _columns, int _rows)
    {
        float columnSpacing = _area.size.x / ( _columns - 1 );
        float rowSpacing = _area.size.z / ( _rows - 1 );
        Vector3 rowOffset = new Vector3( 0, 0, rowSpacing );

        for ( int i = 0; i < _columns; i++ )
        {
            Vector3 columnHead = new Vector3(
                ( _area.center.x - _area.extents.x ) + ( columnSpacing * i ),
                _area.center.y,
                _area.center.z + _area.extents.z
            );

            for ( int j = 0; j < _rows; j++ )
            {
                Vector3 hoverPointPos = columnHead - ( rowOffset * j );
                hoverPointPos = transform.TransformPoint( hoverPointPos );
                GameObject newHoverPoint = Instantiate( HoverPointPrefab, hoverPointPos, Quaternion.identity, HoverPointContainer.transform );
                HoverPoints[( i * _rows ) + j] = newHoverPoint;
            }
        }
    }
    private void Hover()
    {
        // foreach ( Transform hoverPoint in HoverPoints )
        // {
        //     //The ray used at each hover point down from the board
        //     Ray hoverRay = new Ray( hoverPoint.position, -transform.up );
        //     RaycastHit hit;

        //     if ( Physics.Raycast( hoverRay, out hit, HoverHeight, GroundMask ) )
        //     {
        //         float actualHeight = hit.distance;
        //         Vector3 groundNormal = hit.normal;

        //         //Use the respective PID controller to calculate the percentage of hover force to be used
        //         float forcePercent = PIDs[Array.IndexOf( HoverPoints, hoverPoint )].Control( HoverHeight, actualHeight );
        //         //Grapher.Log( forcePercent, "PID" + Array.IndexOf( HoverPoints, hoverPoint ).ToString() );   //plots the PID value in an editor toolTODO: remove when done tuning 

        //         //calculate the adjusted force in the direction of the ground normal
        //         Vector3 adjustedForce = HoverForce * forcePercent * groundNormal;

        //         //Add the force to the rigidbody at the respective hoverpoint's position
        //         RB.AddForceAtPosition( adjustedForce, hoverPoint.position, ForceMode.Acceleration );
        //     }
        // }

        foreach ( GameObject hoverPoint in HoverPoints )
        {
            Vector3 hoverPointPos = hoverPoint.transform.position;
            //The ray used at each hover point down from the board
            Ray hoverRay = new Ray( hoverPointPos, -transform.up );
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
                RB.AddForceAtPosition( adjustedForce, hoverPointPos, ForceMode.Acceleration );
            }
        }
    }
    #endregion

    private void Handling()
    {
        ScaleForceWithSpeedInverse( ref TurnForce, TurnForceMin, TurnForceMax );
        RaycastHit hit;
        if ( IsGrounded( out hit ) )
        {
            Turn();
            ApplySidewaysFriction();    //FIXME: Not sure if this should also run in the air
            ApplyIdleFriction();
            ApplyGroundStickForce( hit );
            Carve();
        }
        else
        {
            AirControl();
        }
    }

    #region Thrust
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
                AirThrust( ThrustInput, thrustDirection );
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
    #endregion

    #region Turning
    private void Turn()
    {
        //Make the Turn Input scale exponentially to get more of a carving feel when steering
        float scaledTurnInput = Mathf.Pow( TurnInput, 3 );
        //Calculate turn force
        Vector3 turnForce = -transform.right * TurnForce * scaledTurnInput;
        //Apply calculated turn force to the rigidbody at the turn motor position
        RB.AddForceAtPosition( turnForce, TurnMotor.position, ForceMode.Acceleration );
    }

    private void Carve()
    {
        if ( IsGettingCarveInput )
        {
            //Make the Turn Input scale exponentially to get more of a carving feel when steering
            float scaledTurnInput = Mathf.Pow( TurnInput, 3 );
            //Calculate turn force
            Vector3 turnForce = -transform.right * CarveForce * scaledTurnInput;
            //Apply calculated turn force to the rigidbody at the turn motor position
            RB.AddForceAtPosition( turnForce, CarveMotor.position, ForceMode.Acceleration );
            ApplyCarveFriction();
        }
    }
    #endregion

    #region Moves
    private void Moves()
    {
        ScaleForceWithSpeed( ref JumpForce, JumpForceMin, JumpForceMax );

        if ( IsCrouching )
        {
            if ( JumpForceCharge <= 1 )
            {
                JumpForceCharge += Time.deltaTime / JumpChargeTime;
            }
        }

        if ( IsGrounded() )
        {
            GroundDash();
        }
        else if ( !IsGrounded() )
        {
            AirDash();
        }
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
            if ( IsGrounded( CoyoteTime.position ) )
            {
                RB.AddForce( transform.up * JumpForce * JumpForceCharge, ForceMode.VelocityChange );
                OnJump.Invoke();
            }
            JumpForceCharge = JumpForceChargeMin;
        }
    }

    public void SideShiftLeft()
    {
        RaycastHit hit;
        if ( IsGrounded( out hit ) )
        {
            Vector3 forceDirection = Vector3.ProjectOnPlane( -transform.right, hit.normal ).normalized;
            RB.AddForceAtPosition( forceDirection * SideShiftForce, SideShiftMotor.position, ForceMode.VelocityChange );
        }
        else
        {
            RB.AddForceAtPosition( -transform.right * SideShiftForce, ThrustMotor.position, ForceMode.VelocityChange );
        }
    }
    public void SideShiftRight()
    {
        RaycastHit hit;
        if ( IsGrounded( out hit ) )
        {
            Vector3 forceDirection = Vector3.ProjectOnPlane( transform.right, hit.normal ).normalized;
            RB.AddForceAtPosition( forceDirection * SideShiftForce, SideShiftMotor.position, ForceMode.VelocityChange );
        }
        else
        {
            RB.AddForceAtPosition( transform.right * SideShiftForce, ThrustMotor.position, ForceMode.VelocityChange );
        }
    }

    void GroundDash()
    {
        if ( IsDashing )
        {
            //TODO: This is where the logic that checks if the player has enough energy would go
            Boost( BoostForce, ThrustDirection );
        }
    }
    void AirDash()
    {
        if ( IsDashing )
        {
            //project the boards forward direction on world xz-plane
            Vector3 thrustDirection = Vector3.ProjectOnPlane( transform.forward, Vector3.up );
            //TODO: This is where the logic that checks if the player has enough energy would go
            Boost( BoostForce, thrustDirection );
        }
    }
    public void Boost(float _boostForce, Vector3 _thrustDirection)
    {
        Vector3 thrustDirection = _thrustDirection;

        //Calculate thrust force
        Vector3 thrustForce = thrustDirection * _boostForce;
        //Apply calculated thrust to the rigidbody at the thrust motor position
        RB.AddForceAtPosition( thrustForce, ThrustMotor.position, ForceMode.Acceleration );
    }
    #endregion

    #region AirControl
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
    #endregion

    #region ExternalForces
    //Applies a force towards the ground, scaled by the body's velocity
    private void ApplyGroundStickForce(RaycastHit _hit)
    {
        if ( StickToGround )
        {
            RaycastHit hit = _hit;

            Vector3 force = -hit.normal * GroundStickForce * ( RB.velocity.magnitude / MaxSpeed );
            RB.AddForce( force, ForceMode.Acceleration );
        }
    }
    private void ApplySidewaysFriction()
    {
        float sidewaysSpeed = Vector3.Dot( RB.velocity, -transform.right );
        RB.AddForce( transform.right * sidewaysSpeed * SidewaysFriction, ForceMode.Acceleration );
    }
    private void ApplyCarveFriction()
    {
        float sidewaysSpeed = Vector3.Dot( RB.velocity, -transform.right );
        RB.AddForce( transform.right * sidewaysSpeed * CarveFriction, ForceMode.Acceleration );
    }
    private void ApplyIdleFriction()
    {
        if ( ThrustInput <= 0.1 && RB.velocity.magnitude <= IdleSpeed )
        {
            float friction = Mathf.Lerp( IdleFriction, 0.0f, RB.velocity.magnitude / IdleSpeed );
            RB.AddForce( -RB.velocity * friction, ForceMode.Acceleration );
        }
    }
    private void ApplyQuadraticDrag()
    {
        //Apply translational drag
        RB.AddForce( -Drag * RB.velocity.normalized * RB.velocity.sqrMagnitude, ForceMode.Acceleration );
        //Apply rotational drag
        RB.AddTorque( -AngularDrag * RB.angularVelocity.normalized * RB.angularVelocity.sqrMagnitude, ForceMode.Acceleration );
    }
    #endregion

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

    #region Ground Checks
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
    //overloaded function that takes a ray origin position as an argument
    private bool IsGrounded(Vector3 _rayOrigin)
    {
        return ( Physics.Raycast( _rayOrigin, -transform.up, GroundStickHeight, GroundMask ) );
    }
    //overloaded function that takes a ray origin position as an argument and gives raycast hit info in an out parameter
    private bool IsGrounded(Vector3 _rayOrigin, out RaycastHit _hit)
    {
        RaycastHit hit;
        bool ray = Physics.Raycast( _rayOrigin, -transform.up, out hit, GroundStickHeight, GroundMask );
        _hit = hit;
        return ray;
    }
    #endregion

    #region Input Setters
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
    public void SetCarveInput(bool _isGettingInput)
    {
        IsGettingCarveInput = _isGettingInput;
    }
    public void SetDashInput(bool _isDashing)
    {
        IsDashing = _isDashing;
    }
    #endregion

    #region Utility
    private void ScaleForceWithSpeedInverse(ref float _force, float _forceMin, float _forceMax)
    {
        _force = _forceMax - ( ( _forceMax - _forceMin ) * ( RB.velocity.magnitude / MaxSpeed ) );
    }
    private void ScaleForceWithSpeed(ref float _force, float _forceMin, float _forceMax)
    {
        _force = _forceMin + ( ( _forceMax - _forceMin ) * ( RB.velocity.magnitude / MaxSpeed ) );
    }
    #endregion

    private void CalculateMaxSpeed()
    {
        if ( IsGrounded() )
        {
            if ( !IsDashing )
            {
                //Calculate the maximum velocity based on the defined ground acceleration force and drag
                MaxSpeed = Mathf.Sqrt( GroundAccelerationForce / Drag );
            }
            else if ( IsDashing )
            {
                //Calculate the maximum velocity based on the defined ground acceleration force, the boost force and drag
                MaxSpeed = Mathf.Sqrt( ( GroundAccelerationForce + BoostForce ) / Drag );
            }
        }
        else if ( !IsGrounded() )
        {
            if ( !IsDashing )
            {
                //Calculate the maximum velocity based on the defined air acceleration force and drag
                MaxSpeed = Mathf.Sqrt( AirAccelerationForce / Drag );
            }
            else if ( IsDashing )
            {
                //Calculate the maximum velocity based on the defined air acceleration force, the boost force and drag
                MaxSpeed = Mathf.Sqrt( ( AirAccelerationForce + BoostForce ) / Drag );
            }
        }
    }

    private void OnDrawGizmosSelected()
    {
        foreach ( var hoverPoint in HoverPoints )
        {
            Gizmos.DrawSphere( hoverPoint.transform.position, 0.05f );
        }
    }

}
