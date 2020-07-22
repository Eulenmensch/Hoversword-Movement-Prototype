using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerBoost : MonoBehaviour
{
    public float BoostForce => _boostForce.magnitude;
    private Vector3 _boostForce;

    private ForceMode _forceMode;

    private Rigidbody _rb;
    private PlayerHandling _handling;
    private PlayerThrust _thrust;


    private void Awake()
    {
        _rb = GetComponent<Rigidbody>();
        _handling = GetComponent<PlayerHandling>();
        _thrust = GetComponent<PlayerThrust>();
    }

    private void FixedUpdate()
    {
        if (_handling.IsBoosting) Boost();
    }

    public void SetBoost(Vector3 force, ForceMode forceMode)
    {
        _boostForce = force;
        _forceMode = forceMode;
        _handling.IsBoosting = true;
    }

    public void StopBoost()
    {
        _handling.IsBoosting = false;
    }

    private void Boost()
    {
        _rb.AddForceAtPosition(_boostForce, _thrust.ThrustMotor.position, _forceMode);
    }
}
