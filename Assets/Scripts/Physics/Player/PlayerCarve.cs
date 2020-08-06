using UnityEngine;

[RequireComponent(typeof(Rigidbody), typeof(PlayerHandling))]
public class PlayerCarve : MonoBehaviour
{
    public float CarveFriction
    {
        get { return carveFriction; }
        private set { carveFriction = value; }
    }

    [SerializeField] private float CarveForce;              //The additional force that makes the board carve
    [SerializeField] private float carveFriction;           //The additional force that keeps the board from sliding sideways during a carve
    [SerializeField] private float TurnThreshold;           //The minimal amount of turn input required to make the carve register
    [SerializeField] private float MaxMiniBoostDuration;    //The maximum duration the carve mini boost can last
    [SerializeField] private float MiniBoostChargeSpeed;    //The rate at which the mini boost charges up
    [SerializeField] private Transform CarveMotor;          //The location where carve force is applied

    private PlayerHandling Handling;
    private Rigidbody RB;
    private int Direction;
    private float MiniBoostDuration;

    private void Start()
    {
        Handling = GetComponent<PlayerHandling>();
        RB = GetComponent<Rigidbody>();
    }

    public void Carve(float _turnInput)
    {
        if (Handling.IsCarving)
        {
            //lock the turn input to either left or right based on initial turn direction
            float directionLockedInput = _turnInput + Direction;
            Vector3 turnForce = -transform.right * CarveForce * directionLockedInput;
            //Apply calculated turn force to the rigidbody at the turn motor position
            RB.AddForceAtPosition(turnForce, CarveMotor.position, ForceMode.Acceleration);
            ChargeMiniBoost();
        }
    }

    public void StartCarve(float _turnInput)
    {
        if (Mathf.Abs(_turnInput) >= TurnThreshold)
        {
            if (_turnInput > 0)
            {
                Direction = 1;
            }
            else if (_turnInput < 0)
            {
                Direction = -1;
            }
            Handling.IsCarving = true;
        }
    }

    public void StopCarve()
    {
        if (Handling.IsCarving)
        {
            Handling.IsCarving = false;
            PlayerEvents.Instance.StartDash(MiniBoostDuration);
            MiniBoostDuration = 0;
        }
    }

    //FIXME: This method currently duplicates the code of PlayerTurn.ApplySidewaysFriction()
    private void ApplyCarveFriction()
    {
        float sidewaysSpeed = Vector3.Dot(RB.velocity, -transform.right);
        RB.AddForce(transform.right * sidewaysSpeed * carveFriction, ForceMode.Acceleration);
    }

    private void ChargeMiniBoost()
    {
        if (MiniBoostDuration <= MaxMiniBoostDuration)
        {
            MiniBoostDuration += MiniBoostChargeSpeed * Time.deltaTime;
        }
    }
}