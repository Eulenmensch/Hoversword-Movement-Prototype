using UnityEngine;
using UnityEngine.InputSystem;

[RequireComponent(typeof(GroundCheck), typeof(Rigidbody))]
public class PlayerHandling : MonoBehaviour/*, IMove*/
{

    public float MaxSpeed { get; private set; }

    //Public Flags
    public bool IsActive { get; set; } = true;
    public bool IsDashing { get; set; }
    public bool IsBoosting { get; set; }
    public bool IsCarving { get; set; }
    public bool IsAirborne { get; private set; }
    public bool IsGrounded { get; private set; }
    public bool IsJumping { get; set; }
    public bool IsJumpCharging { get; private set; }

    //Input Fields
    public float TurnInput { get; private set; }
    public float ThrustInput { get; private set; }
    public float PitchInput { get; private set; }

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

    private CombatController Combat;


    //Flags
    private bool CanDash;
    private bool CanJump;
    private bool CanCarve;
    private bool IsFalling;

    private void OnEnable()
    {
        PlayerEvents.Instance.OnJumpCharge += SetCanCarveFalse;
        PlayerEvents.Instance.OnStartDashCharge += SetCanCarveFalse;
        PlayerEvents.Instance.OnStartAim += SetCanCarveFalse;
        PlayerEvents.Instance.OnStartKickAttack += SetCanCarveFalse;

        PlayerEvents.Instance.OnLand += SetCanCarveTrue;
        PlayerEvents.Instance.OnJumpCancel += SetCanCarveTrue;
        PlayerEvents.Instance.OnStopDash += SetCanCarveTrue;
        PlayerEvents.Instance.OnStopDashCharge += SetCanCarveTrue;
        PlayerEvents.Instance.OnStopAim += SetCanCarveTrue;
        PlayerEvents.Instance.OnStopKickAttack += SetCanCarveTrue;
    }

    private void OnDisable()
    {
        PlayerEvents.Instance.OnJumpCharge -= SetCanCarveFalse;
        PlayerEvents.Instance.OnStartDashCharge -= SetCanCarveFalse;
        PlayerEvents.Instance.OnStartAim -= SetCanCarveFalse;
        PlayerEvents.Instance.OnStartKickAttack -= SetCanCarveFalse;

        PlayerEvents.Instance.OnLand -= SetCanCarveTrue;
        PlayerEvents.Instance.OnJumpCancel -= SetCanCarveTrue;
        PlayerEvents.Instance.OnStopDash -= SetCanCarveTrue;
        PlayerEvents.Instance.OnStopDashCharge -= SetCanCarveTrue;
        PlayerEvents.Instance.OnStopAim -= SetCanCarveTrue;
        PlayerEvents.Instance.OnStopKickAttack -= SetCanCarveTrue;
    }

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
        Combat = GetComponent<CombatController>();

        CanCarve = true;
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.J))
        {
            IsActive = !IsActive;
        }
    }

    private void FixedUpdate()
    {
        if (!IsActive)
            return;

        RaycastHit hit;
        IsGrounded = GroundCheck.IsGrounded(out hit);

        CalculateMaxSpeed();
        SetCanDash();
        SetCanJump();
        SetAnimatorGrounded();
        SetFalling();

        CoyoteTime();
        Land();
        Thrust(hit);
        Turn();
        PlayerAirControl.AirControl(PitchInput, IsGrounded, IsDashing);
        Carve();
    }

    private void CalculateMaxSpeed()
    {
        float force = IsGrounded ? PlayerThrust.GroundAccelerationForce : PlayerThrust.AirAccelerationForce;
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

    private void Thrust(RaycastHit _hit)
    {
        PlayerThrust.Thrust(ThrustInput, IsGrounded, _hit);
        if (IsGrounded)
        {
            PlayerFriction.ApplyIdleFriction(ThrustInput, RB);
        }
    }

    private void Turn()
    {
        if (!IsCarving)
        {
            PlayerTurn.Turn(TurnInput);
            PlayerFriction.ApplySidewaysFriction(RB, PlayerTurn.TurnFriction);
        }
    }

    private void Carve()
    {
        PlayerCarve.Carve(TurnInput);
        if (IsCarving)
        {
            PlayerFriction.ApplySidewaysFriction(RB, PlayerCarve.CarveFriction);
        }
    }
    public void SetCarve(InputAction.CallbackContext context)
    {
        if (CanCarve)
        {
            if (IsGrounded)
            {
                if (context.started)
                {
                    PlayerCarve.StartCarve(TurnInput);
                }
            }
        }
        if (context.canceled)
        {
            PlayerCarve.StopCarve();
        }

    }

    public void Dash(InputAction.CallbackContext context)
    {
        if (CanDash)
        {
            if (context.started)
            {
                PlayerDash.StartCharge();
                BoardFX.SetDashing(true);
                PlayerEvents.Instance.StartDashCharge();
            }
            else if (context.canceled)
            {
                PlayerDash.StopCharge();
                BoardFX.SetDashing(false);
                PlayerEvents.Instance.StopDashCharge();
            }
        }
    }

    public void Jump(InputAction.CallbackContext context)
    {
        if (CanJump)
        {
            if (context.started)
            {
                PlayerJump.ResetJumpCharge();
                IsJumpCharging = true;
                BoardFX.SetCrouching(true);
                PlayerEvents.Instance.StartJumpCharge();
                IsJumping = true;
            }
            else if (context.canceled && IsJumping && IsJumpCharging)
            {
                PlayerJump.Jump();
                PlayerJump.StartLandingBuffer();
                BoardFX.PlayJumpJetParticles();
                PlayerJump.ResetJumpCharge();
                IsJumpCharging = false;
                BoardFX.SetCrouching(false);
                PlayerEvents.Instance.Jump();
            }
        }
        else if (context.canceled)
        {
            PlayerEvents.Instance.HandleJumpAfterAim();
            IsJumpCharging = false;
        }
    }

    private void Land()
    {
        if (!IsGrounded)
        {
            IsAirborne = true;
        }
        if (IsGrounded)
        {
            if (animator.GetCurrentAnimatorStateInfo(0).IsName("Jump Falling"))
            {
                PlayerEvents.Instance.Land();
                PlayerJump.StopLandingBuffer();
                if (!IsJumpCharging)
                {
                    IsJumping = false;
                }
            }
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

    private void SetCanDash()
    {
        if (IsCarving || IsJumpCharging || Combat.isAiming || (Combat.attackState == CombatController.AttackStates.Flip))
        {
            CanDash = false;
            animator.SetBool("CanBoost", false);
        }
        else
        {
            CanDash = true;
            animator.SetBool("CanBoost", true);
        }
    }

    private void SetCanJump()
    {
        if (IsCarving || IsDashing || PlayerDash.IsCharging || Combat.isAiming || (Combat.attackState == CombatController.AttackStates.Flip))
        {
            CanJump = false;
        }
        else
        {
            CanJump = true;
        }
    }

    private void SetCanCarveTrue()
    {
        if (!IsJumpCharging)
        {
            CanCarve = true;
        }
    }
    private void SetCanCarveFalse() { CanCarve = false; }


    private void SetFalling()
    {
        if (animator.GetCurrentAnimatorStateInfo(0).IsName("Jump Falling"))
        {
            if (!IsFalling)
            {
                IsFalling = true;
                PlayerEvents.Instance.JumpFall();
            }
        }
        else
        {
            IsFalling = false;
        }
    }

    private void SetAnimatorGrounded()
    {
        animator.SetBool("Grounded", IsGrounded);
    }
}