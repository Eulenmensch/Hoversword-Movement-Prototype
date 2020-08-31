using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using UnityEditor;
using UnityEngine;
using UnityEngine.Animations;

public class RotationMovement : MonoBehaviour, IMovement
{
    [SerializeField] private bool _moveOnStart;
    public bool IsMoving { get; set; }
    [SerializeField] private bool _isLooping;

    public enum RotationAxis { X, Y, Z }
    [Header("Rotation")]
    [SerializeField] private RotationAxis _axis = RotationAxis.Y;
    [SerializeField] private float _speed = 50f;
    [SerializeField] private Ease ease = Ease.Linear;

    [Header("Angles")]
    [SerializeField] private float _startAngle = 0;
    [SerializeField] private float _endAngle = 0;

    [Header("Full Rotation")]
    [SerializeField] private bool _fullRotation;
    public enum RotationDirection { clockwise, antiClockwise }
    [SerializeField] private RotationDirection _rotationDirection;

    [SerializeField] private bool _useEuler = true;

    private float _angle;
    private Vector3 rotationAxis = Vector3.zero;

    private bool _flip;

    private void Start()
    {
        SetStartingPosition();
        //SetRotationAxis();

        if (_moveOnStart) Move();
    }

    public void Move()
    {
        IsMoving = true;
        if (!_fullRotation)
        {
            if (_isLooping)
                DOTween.To(() => _angle, x => _angle = x, _endAngle, _speed).SetSpeedBased().SetLoops(-1, LoopType.Yoyo).SetEase(ease);
            else
            {
                float targetAngle = _flip ? _startAngle : _endAngle;
                _flip = !_flip;
                DOTween.To(() => _angle, x => _angle = x, targetAngle, _speed).SetSpeedBased().SetEase(ease);
            }
        }
    }

    private void Update()
    {
        if (IsMoving && _fullRotation) FullRotation();

        if (_useEuler)
        {
            if (_axis == RotationAxis.X)
                transform.localEulerAngles = new Vector3(_angle, 0, 0);
            else if (_axis == RotationAxis.Y)
                transform.localEulerAngles = new Vector3(0, _angle, 0);
            else
                transform.localEulerAngles = new Vector3(0, 0, _angle);
        }
        else
        {
            SetRotationAxis();
            Quaternion rot = Quaternion.AngleAxis(_angle, rotationAxis);
            transform.rotation = rot;
        }
        //Debug.DrawLine(transform.position, transform.position + rotationAxis, Color.red);
    }

    private void FullRotation()
    {
        int sign = _rotationDirection == RotationDirection.clockwise ? -1 : 1;
        _angle = _angle + (sign * _speed * Time.deltaTime);
        if (_angle >= 360f)
        {
            _angle -= 360;
        }
        else if (_angle <= 0)
        {
            _angle += 360;
        }
    }

    private void SetStartingPosition()
    {
        SetRotationAxis();
        Quaternion startRot = Quaternion.AngleAxis(_startAngle, rotationAxis);

        transform.localRotation = startRot;
        _angle = _startAngle;
    }

    private void SetRotationAxis()
    {
        rotationAxis = (_axis == RotationAxis.Z) ? transform.forward : (_axis == RotationAxis.Y) ? transform.up : transform.right;
        //Debug.DrawLine(transform.position, transform.position + rotationAxis, Color.red);
    }

    private void OnValidate()
    {
        if (enabled)
        {
            SetStartingPosition();
        }
    }

#if UNITY_EDITOR
    private void OnDrawGizmosSelected()
    {
        SetRotationAxis();

        Quaternion startRot =  transform.parent.rotation * Quaternion.AngleAxis(_startAngle, rotationAxis);
        Vector3 start = startRot * Vector3.up;

        Gizmos.color = Color.black;
        Gizmos.DrawLine(transform.position, transform.position + start * 1.25f);

        if (!_fullRotation)
        {
            Quaternion endRot = transform.parent.rotation * Quaternion.AngleAxis(_endAngle, rotationAxis);
            Vector3 end = endRot * Vector3.up;

            Gizmos.color = Color.grey;
            Gizmos.DrawLine(transform.position, transform.position + end * 1.25f);

            Handles.color = Color.grey;
            Handles.DrawSolidArc(transform.position, rotationAxis, start, _endAngle - _startAngle, 1f);
        }
    }
#endif
}
