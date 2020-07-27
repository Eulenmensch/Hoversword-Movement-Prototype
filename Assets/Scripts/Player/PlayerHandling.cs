using UnityEngine;
using UnityEngine.InputSystem;

[RequireComponent(typeof(GroundCheck))]
public class PlayerHandling : MonoBehaviour/*, IMove*/
{
    public float MaxSpeed { get; private set; }
    public bool IsDashing { get; set; }
    public bool IsBoosting { get; set; }
    public bool IsGrounded { get; private set; }

    [SerializeField] PlayerEngineFX BoardFX;
    //Settings

    //References
    private GroundCheck GroundCheck;
    private PlayerThrust Thrust;
    private PlayerTurn Turn;
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

    //Flags
    private bool CenterOfMassSet;

    private void Start()
    {
        GroundCheck = GetComponent<GroundCheck>();
        Thrust = GetComponent<PlayerThrust>();
        Turn = GetComponent<PlayerTurn>();
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
        IsGrounded = GroundCheck.IsGrounded(out hit);

        CalculateMaxSpeed();
        // AdjustCenterOfMassInAir();
        CoyoteTime();
        Thrust.Thrust(ThrustInput, IsGrounded, hit);
        Turn.Turn(TurnInput);
        AirControl.AirControl(PitchInput, IsGrounded);
    }

    private void CalculateMaxSpeed()
    {
        float force = IsGrounded ? Thrust.GroundAccelerationForce : Thrust.AirAccelerationForce;
        if (IsDashing) force += PlayerDash.BoostForce;
        if (IsBoosting) force += PlayerBoost.BoostForce;
        MaxSpeed = Mathf.Sqrt(force / QuadraticDrag.Drag);
    }

    public void GetMoveInput(InputAction.CallbackContext context)
    {
        Vector2 inputVector = context.ReadValue<Vector2>();
        ThrustInput = inputVector.y;
        TurnInput = inputVector.x;
        BoardFX.SetMoveInput(inputVector.y, inputVector.x);
    }

    public void GetPitchInput(InputAction.CallbackContext context)
    {
        PitchInput = context.ReadValue<Vector2>().y;
    }

    public void Dash(InputAction.CallbackContext context)
    {
        if (context.started)
        {
            PlayerDash.StartCharge();
            BoardFX.SetDashing(true);
        }
        else if (context.canceled)
        {
            PlayerDash.StopCharge();
            BoardFX.SetDashing(false);
        }
    }

    public void Jump(InputAction.CallbackContext context)
    {
        if (context.started)
        {
            PlayerJump.SetCharging(true);
            BoardFX.SetCrouching(true);
        }
        else if (context.canceled)
        {
            PlayerJump.Jump();
            BoardFX.PlayJumpJetParticles();
            PlayerJump.SetCharging(false);
            BoardFX.SetCrouching(false);
        }
    }

    private void CoyoteTime()
    {
        if (!IsGrounded)
        {
            PlayerJump.StartCoyoteTime();
        }
        else
        {
            PlayerJump.StopCoyoteTime();
        }
    }

    private void AdjustCenterOfMassInAir()
    {
        if (!IsGrounded && !CenterOfMassSet)
        {
            CenterOfMass.SetCenterOfMass(transform.position);
            CenterOfMassSet = true;
        }
        else if (IsGrounded && CenterOfMassSet)
        {
            CenterOfMass.SetCenterOfMass(CenterOfMass.CenterOfMassTransform.localPosition);
            CenterOfMassSet = false;
        }
    }
}