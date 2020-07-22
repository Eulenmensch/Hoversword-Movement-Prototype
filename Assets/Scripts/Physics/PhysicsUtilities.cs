using UnityEngine;
public static class PhysicsUtilities
{
    public static void ScaleForceWithSpeedInverse(ref float _force, float _forceMin, float _forceMax, Rigidbody _rigidbody, float _maxSpeed)
    {
        _force = _forceMax - ( ( _forceMax - _forceMin ) * ( _rigidbody.velocity.magnitude / _maxSpeed ) );
    }
    public static void ScaleForceWithSpeed(ref float _force, float _forceMin, float _forceMax, Rigidbody _rigidbody, float _maxSpeed)
    {
        _force = _forceMin + ( ( _forceMax - _forceMin ) * ( _rigidbody.velocity.magnitude / _maxSpeed ) );
    }
}