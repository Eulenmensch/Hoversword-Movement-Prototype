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

    public float DashTime { get; private set; }
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
    // private float DashTime;

    private void OnEnable()
    {
        PlayerEvents.Instance.OnStartDash += StartDash;
    }

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
        Dash(DashTime);
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
                StartDash(Duration);
            }
        }
    }

    public void StartDash(float _duration)
    {
        Handling.IsDashing = true;
        DashTime = _duration;
    }
    private void StopDash()
    {
        Handling.IsDashing = false;
        Handling.Animator.SetTrigger("StopDash");
    }

    private void Dash(float _duration)
    {
        if (Handling.IsDashing)
        {
            Boost();
            DashTimer += Time.deltaTime;
            if (DashTimer >= _duration)
            {
                StopDash();
                DashTimer = 0;
            }
        }
    }

    private void Boost()
    {
        Vector3 thrustForce = transform.forward * BoostForce;
        //Apply calculated thrust to the rigidbody at the thrust motor position
        RB.AddForceAtPosition(thrustForce, Thrust.ThrustMotor.position, ForceMode.Acceleration);
    }
}