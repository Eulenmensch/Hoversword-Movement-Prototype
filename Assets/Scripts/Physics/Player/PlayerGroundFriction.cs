using UnityEngine;

public class PlayerGroundFriction : MonoBehaviour
{
    [SerializeField] float IdleSpeed;                   //The velocity at which the body is considered idle
    [SerializeField] float IdleFriction;                //The force that keeps the board from sliding when idle
    [SerializeField] private float TurnFriction;        //The force that keeps the board from sliding sideways
    [SerializeField] private float LerpTime;

    private float SidewaysFriction;

    private void Start()
    {
        SidewaysFriction = TurnFriction;
    }

    public void ApplyIdleFriction(float _thrustInput, Rigidbody _rb)
    {
        if ( _thrustInput <= 0.1 && _rb.velocity.magnitude <= IdleSpeed )
        {
            float friction = Mathf.Lerp( IdleFriction, 0.0f, _rb.velocity.magnitude / IdleSpeed );
            _rb.AddForce( -_rb.velocity * friction, ForceMode.Acceleration );
            _rb.AddTorque( -_rb.angularVelocity * friction, ForceMode.Acceleration );
        }
    }

    public void ApplySidewaysFriction(Rigidbody _rb, float _friction)
    {
        SidewaysFriction = Mathf.Lerp( SidewaysFriction, _friction, LerpTime );
        float sidewaysSpeed = Vector3.Dot( _rb.velocity, -transform.right );
        _rb.AddForce( transform.right * sidewaysSpeed * SidewaysFriction, ForceMode.Acceleration );
    }
}