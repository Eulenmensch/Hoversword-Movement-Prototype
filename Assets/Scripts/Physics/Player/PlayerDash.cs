using UnityEngine;

[RequireComponent(typeof(PlayerHandling), typeof(Rigidbody))]
public class PlayerDash : MonoBehaviour
{
    enum BoostMode
    {
        NoHeightGain,
        HeightGain
    }
    public float BoostForce                     //The additional force applied to the body while boosting
    {
        get { return boostForce; }
        private set { boostForce = value; }
    }
    public float ChargeTime
    {
        get { return chargeTime; }
        private set { boostForce = value; }
    }
    public float Duration
    {
        get { return duration; }
        private set { duration = value; }
    }
    public bool IsCharging { get; private set; }


    [SerializeField] float boostForce;
    [SerializeField] float chargeTime;
    [SerializeField] float duration;
    [SerializeField] BoostMode Mode;

    private Rigidbody RB;
    private PlayerHandling Handling;
    private PlayerThrust Thrust;
    private float ChargeTimer;
    private float DashTimer;

    private void Start()
    {
        RB = GetComponent<Rigidbody>();
        Handling = GetComponent<PlayerHandling>();
        Thrust = GetComponent<PlayerThrust>();

        ChargeTimer = 0;
        DashTimer = 0;
    }

    private void FixedUpdate()
    {
        Charge();
        Dash();
    }

    public void StartCharge()
    {
        IsCharging = true;
    }
    public void StopCharge()
    {
        IsCharging = false;
        ChargeTimer = 0;
    }

    private void Charge()
    {
        if (IsCharging)
        {
            ChargeTimer += Time.deltaTime;
            if (ChargeTimer >= chargeTime)
            {
                ChargeTimer = 0;
                IsCharging = false;
                StartDash();
            }
        }
    }

    private void StartDash()
    {
        Handling.IsDashing = true;
    }
    private void StopDash()
    {
        Handling.IsDashing = false;
    }

    private void Dash()
    {
        if (Handling.IsDashing)
        {
            Boost();
            DashTimer += Time.deltaTime;
            if (DashTimer >= duration)
            {
                StopDash();
                DashTimer = 0;
            }
        }
    }

    private void Boost()
    {
        Vector3 thrustForce = Vector3.zero;
        if (Mode == BoostMode.NoHeightGain)
        {
            //Calculate thrust force
            thrustForce = Thrust.ThrustDirection * BoostForce;
        }
        else if (Mode == BoostMode.HeightGain)
        {
            thrustForce = transform.forward * BoostForce;
        }
        //Apply calculated thrust to the rigidbody at the thrust motor position
        RB.AddForceAtPosition(thrustForce, Thrust.ThrustMotor.position, ForceMode.Acceleration);
    }
}