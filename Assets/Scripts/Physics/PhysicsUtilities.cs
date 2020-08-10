using UnityEngine;
public static class PhysicsUtilities
{
    public static void ScaleValueWithSpeedInverse(ref float _value, float _valueMin, float _valueMax, Rigidbody _rigidbody, float _maxSpeed)
    {
        _value = _valueMax - ( ( _valueMax - _valueMin ) * ( _rigidbody.velocity.magnitude / _maxSpeed ) );
    }
    public static void ScaleValueWithSpeed(ref float _value, float _valueMin, float _valueMax, Rigidbody _rigidbody, float _maxSpeed)
    {
        _value = _valueMin + ( ( _valueMax - _valueMin ) * ( _rigidbody.velocity.magnitude / _maxSpeed ) );
    }
}