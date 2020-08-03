using UnityEngine;
using UnityEngine.InputSystem;

[RequireComponent( typeof( GroundCheck ) )]
public class PlayerHandling : MonoBehaviour/*, IMove*/
{
    public float MaxSpeed { get; private set; }
    public bool IsDashing { get; set; }
    public bool IsBoosting { get; set; }
    public bool IsAirborne { get; private set; }
    public bool IsGrounded { get; private set; }

    public Animator Animator
    {
        get { return animator; }
        private set { animator = value; }
    }

    [SerializeField] PlayerEngineFX BoardFX;
    [SerializeField] Animator animator;
    //Settings

    //References
    private GroundCheck GroundCheck;
    private PlayerThrust Thrust;
    private PlayerTurn Turn;
    private PlayerCarve PlayerCarve;
    private PlayerDash PlayerDash;
    private PlayerBoost PlayerBoost;
    private PlayerJump PlayerJump;
    private PlayerAirControl AirControl;
    private CustomCenterOfMass CenterOfMass;
    private QuadraticDrag QuadraticDrag;

    //Input Fields
    private float ThrustInput;
    private float TurnInput;
    private float PitchInput;

    private void Start()
    {
        GroundCheck = GetComponent<GroundCheck>();
        Thrust = GetComponent<PlayerThrust>();
        Turn = GetComponent<PlayerTurn>();
        PlayerCarve = GetComponent<PlayerCarve>();
        PlayerDash = GetComponent<PlayerDash>();
        PlayerBoost = GetComponent<PlayerBoost>();
        PlayerJump = GetComponent<PlayerJump>();
        AirControl = GetComponent<PlayerAirControl>();
        QuadraticDrag = GetComponent<QuadraticDrag>();
        CenterOfMass = GetComponent<CustomCenterOfMass>();
    }

    private void FixedUpdate()
    {
        RaycastHit hit;
        IsGrounded = GroundCheck.IsGrounded( out hit );

        CalculateMaxSpeed();
        CoyoteTime();
        Land();
        Thrust.Thrust( ThrustInput, IsGrounded, hit );
        Turn.Turn( TurnInput );
        AirControl.AirControl( PitchInput, IsGrounded );
    }

    private void CalculateMaxSpeed()
    {
        float force = IsGrounded ? Thrust.GroundAccelerationForce : Thrust.AirAccelerationForce;
        if ( IsDashing ) force += PlayerDash.BoostForce;
        if ( IsBoosting ) force += PlayerBoost.BoostForce;
        MaxSpeed = Mathf.Sqrt( force / QuadraticDrag.Drag );
    }

    public void GetMoveInput(InputAction.CallbackContext context)
    {
        Vector2 inputVector = context.ReadValue<Vector2>();
        ThrustInput = inputVector.y;
        TurnInput = inputVector.x;
        BoardFX.SetMoveInput( inputVector.y, inputVector.x );
    }

    public void GetPitchInput(InputAction.CallbackContext context)
    {
        PitchInput = context.ReadValue<Vector2>().y;
    }

    public void Carve(InputAction.CallbackContext context)
    {
        if ( context.started )
        {
            PlayerCarve.SetCarving( true );
        }
        else if ( context.canceled )
        {
            PlayerCarve.SetCarving( false );
        }
    }

    public void Dash(InputAction.CallbackContext context)
    {
        if ( context.started )
        {
            PlayerDash.StartCharge();
            BoardFX.SetDashing( true );
            animator.SetTrigger( "StartDash" );
        }
        else if ( context.canceled )
        {
            PlayerDash.StopCharge();
            BoardFX.SetDashing( false );
            animator.SetTrigger( "CancelDash" );
        }
    }

    public void Jump(InputAction.CallbackContext context)
    {
        if ( context.started )
        {
            PlayerJump.SetCharging( true );
            BoardFX.SetCrouching( true );
            animator.SetTrigger( "StartJumpCharge" );
        }
        else if ( context.canceled )
        {
            PlayerJump.Jump();
            BoardFX.PlayJumpJetParticles();
            PlayerJump.SetCharging( false );
            BoardFX.SetCrouching( false );
            animator.SetTrigger( "StartJump" );
        }
    }

    private void Land()
    {
        if ( !IsGrounded )
        {
            IsAirborne = true;
        }
        else if ( IsAirborne && IsGrounded )
        {
            IsAirborne = false;
            //this is so that the trigger isn't set when merely falling, which causes the animator to get stuck
            if ( animator.GetCurrentAnimatorStateInfo( 0 ).IsName( "Jump Falling" ) )
            {
                animator.SetTrigger( "StopJump" );
            }
        }
    }

    private void CoyoteTime()
    {
        if ( !IsGrounded )
        {
            PlayerJump.StartCoyoteTime();
        }
        else
        {
            PlayerJump.StopCoyoteTime();
        }
    }
}