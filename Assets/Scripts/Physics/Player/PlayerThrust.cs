using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent( typeof( Rigidbody ), typeof( GroundCheck ) )]
public class PlayerThrust : MonoBehaviour
{
    public float GroundAccelerationForce;                       //The force that accelerates the board in its forward direction, projected on the ground
    public float AirAccelerationForce;                          //The force that accelerates the board in the air 
    [SerializeField] float IdleSpeed;                           //The velocity at which the body is considered idle
    [SerializeField] float IdleFriction;                        //The force that keeps the board from sliding when idle
    public Transform ThrustMotor;                               //The location where acceleration force is applied

    [HideInInspector] public Vector3 ThrustDirection;

    //References
    private Rigidbody RB;
    private PlayerHandling Handling;

    private void Start()
    {
        RB = GetComponent<Rigidbody>();
        Handling = GetComponent<PlayerHandling>();
    }

    #region Thrust
    public void Thrust(float _thrustInput, bool _grounded, RaycastHit _hit)
    {
        if ( !_grounded || Handling.IsDashing )
        {
            //in air project thrust direction on world up
            ApplyThrustForce( _thrustInput, AirAccelerationForce, Vector3.up, RB.worldCenterOfMass );
        }
        else if ( _grounded )
        {
            //on ground project thrust direction on ground up
            ApplyThrustForce( _thrustInput, GroundAccelerationForce, _hit.normal, ThrustMotor.position );
        }

        // else
        // {
        //     //in air project thrust direction on world up
        //     ApplyThrustForce( _thrustInput, AirAccelerationForce, Vector3.up, RB.worldCenterOfMass );
        // }
    }

    private void ApplyThrustForce(float _thrustInput, float _accelerationForce, Vector3 _projectedPlaneNormal, Vector3 _forcePosition)
    {
        ThrustDirection = Vector3.ProjectOnPlane( transform.forward, _projectedPlaneNormal );
        Vector3 thrustForce = ThrustDirection * _accelerationForce * _thrustInput;
        RB.AddForceAtPosition( thrustForce, _forcePosition, ForceMode.Acceleration );
    }
    #endregion

    private void ApplyIdleFriction(float _thrustInput)
    {
        if ( _thrustInput <= 0.1 && RB.velocity.magnitude <= IdleSpeed )
        {
            float friction = Mathf.Lerp( IdleFriction, 0.0f, RB.velocity.magnitude / IdleSpeed );
            RB.AddForce( -RB.velocity * friction, ForceMode.Acceleration );
            RB.AddTorque( -RB.angularVelocity * friction, ForceMode.Acceleration );
        }
    }
}
