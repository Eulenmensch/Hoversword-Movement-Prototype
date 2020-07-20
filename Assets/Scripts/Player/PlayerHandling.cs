using UnityEngine;
using UnityEngine.InputSystem;

[RequireComponent( typeof( GroundCheck ) )]
public class PlayerHandling : MonoBehaviour, IMove
{
    public float MaxSpeed { get; private set; }
    public bool IsDashing { get; set; }
    public bool IsGrounded { get; private set; }

    [SerializeField] PlayerEngineFX BoardFX;
    //Settings

    //References
    private GroundCheck GroundCheck;
    private PlayerThrust Thrust;
    private PlayerTurn Turn;
    private PlayerDash PlayerDash;
    private PlayerJump PlayerJump;
    private PlayerAirControl AirControl;
    private QuadraticDrag QuadraticDrag;

    //Private Fields
    private float ThrustInput;
    private float TurnInput;
    private float PitchInput;

    private void Start()
    {
        GroundCheck = GetComponent<GroundCheck>();
        Thrust = GetComponent<PlayerThrust>();
        Turn = GetComponent<PlayerTurn>();
        PlayerDash = GetComponent<PlayerDash>();
        PlayerJump = GetComponent<PlayerJump>();
        AirControl = GetComponent<PlayerAirControl>();
        QuadraticDrag = GetComponent<QuadraticDrag>();
    }
    private void FixedUpdate()
    {
        RaycastHit hit;
        IsGrounded = GroundCheck.IsGrounded( out hit );

        CalculateMaxSpeed();
        CoyoteTime();
        Thrust.Thrust( ThrustInput, IsGrounded, hit );
        Turn.Turn( TurnInput );
        AirControl.AirControl( PitchInput, IsGrounded );
    }

    private void CalculateMaxSpeed()
    {
        if ( IsGrounded )
        {
            if ( !IsDashing )
            {
                //Calculate the maximum velocity based on the defined ground acceleration force and drag
                MaxSpeed = Mathf.Sqrt( Thrust.GroundAccelerationForce / QuadraticDrag.Drag );
            }
            else if ( IsDashing )
            {
                //Calculate the maximum velocity based on the defined ground acceleration force, the boost force and drag
                MaxSpeed = Mathf.Sqrt( ( Thrust.GroundAccelerationForce + PlayerDash.BoostForce ) / QuadraticDrag.Drag );
            }
        }
        else
        {
            if ( !IsDashing )
            {
                //Calculate the maximum velocity based on the defined air acceleration force and drag
                MaxSpeed = Mathf.Sqrt( Thrust.AirAccelerationForce / QuadraticDrag.Drag );
            }
            else if ( IsDashing )
            {
                //Calculate the maximum velocity based on the defined air acceleration force, the boost force and drag
                MaxSpeed = Mathf.Sqrt( ( Thrust.AirAccelerationForce + PlayerDash.BoostForce ) / QuadraticDrag.Drag );
            }
        }
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

    public void Dash(InputAction.CallbackContext context)
    {
        if ( context.started )
        {
            PlayerDash.StartCharge();
            BoardFX.SetDashing( true );
        }
        else if ( context.canceled )
        {
            PlayerDash.StopCharge();
            BoardFX.SetDashing( false );
        }
    }

    public void Jump(InputAction.CallbackContext context)
    {
        if ( context.started )
        {
            PlayerJump.SetCharging( true );
            BoardFX.SetCrouching( true );
        }
        else if ( context.canceled )
        {
            PlayerJump.Jump();
            BoardFX.PlayJumpJetParticles();
            PlayerJump.SetCharging( false );
            BoardFX.SetCrouching( false );
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