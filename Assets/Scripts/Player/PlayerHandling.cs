using UnityEngine;
using UnityEngine.InputSystem;

[RequireComponent( typeof( GroundCheck ), typeof( Rigidbody ) )]
public class PlayerHandling : MonoBehaviour/*, IMove*/
{
    public float MaxSpeed { get; private set; }
    public bool IsDashing { get; set; }
    public bool IsBoosting { get; set; }
    public bool IsCarving { get; set; }
    public bool IsAirborne { get; private set; }
    public bool IsGrounded { get; private set; }

    public float TurnInput { get; private set; }

    public Rigidbody RB { get; private set; }

    [SerializeField] PlayerEngineFX BoardFX;
    [SerializeField] Animator animator;
    //Settings

    //References
    private GroundCheck GroundCheck;
    private PlayerThrust PlayerThrust;
    private PlayerTurn PlayerTurn;
    private PlayerCarve PlayerCarve;
    private PlayerGroundFriction PlayerFriction;
    private PlayerDash PlayerDash;
    private PlayerBoost PlayerBoost;
    private PlayerJump PlayerJump;
    private PlayerAirControl PlayerAirControl;
    private CustomCenterOfMass CenterOfMass;
    private QuadraticDrag QuadraticDrag;
    // private Rigidbody RB;

    //Input Fields
    private float ThrustInput;
    // private float TurnInput;
    private float PitchInput;

    private void Start()
    {
        GroundCheck = GetComponent<GroundCheck>();
        PlayerThrust = GetComponent<PlayerThrust>();
        PlayerTurn = GetComponent<PlayerTurn>();
        PlayerCarve = GetComponent<PlayerCarve>();
        PlayerFriction = GetComponent<PlayerGroundFriction>();
        PlayerDash = GetComponent<PlayerDash>();
        PlayerBoost = GetComponent<PlayerBoost>();
        PlayerJump = GetComponent<PlayerJump>();
        PlayerAirControl = GetComponent<PlayerAirControl>();
        QuadraticDrag = GetComponent<QuadraticDrag>();
        CenterOfMass = GetComponent<CustomCenterOfMass>();
        RB = GetComponent<Rigidbody>();
    }

    private void FixedUpdate()
    {
        RaycastHit hit;
        IsGrounded = GroundCheck.IsGrounded( out hit );

        CalculateMaxSpeed();
        CoyoteTime();
        Land();
        Thrust( hit );
        Turn();
        PlayerAirControl.AirControl( PitchInput, IsGrounded, IsDashing );
        Carve();
    }

    private void CalculateMaxSpeed()
    {
        float force = IsGrounded ? PlayerThrust.GroundAccelerationForce : PlayerThrust.AirAccelerationForce;
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

    private void Thrust(RaycastHit _hit)
    {
        PlayerThrust.Thrust( ThrustInput, IsGrounded, _hit );
        if ( IsGrounded )
        {
            PlayerFriction.ApplyIdleFriction( ThrustInput, RB );
        }
    }

    private void Turn()
    {
        if ( !IsCarving )
        {
            PlayerTurn.Turn( TurnInput );
            PlayerFriction.ApplySidewaysFriction( RB, PlayerTurn.TurnFriction );
        }
    }

    private void Carve()
    {
        PlayerCarve.Carve( TurnInput );
        if ( IsCarving )
        {
            PlayerFriction.ApplySidewaysFriction( RB, PlayerCarve.CarveFriction );
        }
    }
    public void SetCarve(InputAction.CallbackContext context)
    {
        if ( context.started )
        {
            PlayerCarve.StartCarve( TurnInput );
        }
        else if ( context.canceled )
        {
            PlayerCarve.StopCarve();
        }
    }

    public void Dash(InputAction.CallbackContext context)
    {
        if ( context.started )
        {
            PlayerDash.StartCharge();
            BoardFX.SetDashing( true );
            // animator.SetTrigger( "StartDash" );
            PlayerEvents.Instance.StartDashCharge();
        }
        else if ( context.canceled )
        {
            PlayerDash.StopCharge();
            BoardFX.SetDashing( false );
            // animator.SetTrigger( "CancelDash" );
            PlayerEvents.Instance.StopDashCharge();
        }
    }

    public void Jump(InputAction.CallbackContext context)
    {
        if ( context.started )
        {
            PlayerJump.SetCharging( true );
            BoardFX.SetCrouching( true );
            // animator.SetTrigger( "StartJumpCharge" );
            PlayerEvents.Instance.StartJumpCharge();
        }
        else if ( context.canceled )
        {
            PlayerJump.Jump();
            BoardFX.PlayJumpJetParticles();
            PlayerJump.SetCharging( false );
            BoardFX.SetCrouching( false );
            // animator.SetTrigger( "StartJump" );
            PlayerEvents.Instance.Jump();
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
                // animator.SetTrigger( "StopJump" );
                PlayerEvents.Instance.Land();
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