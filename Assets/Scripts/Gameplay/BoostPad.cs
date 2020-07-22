using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Animations.Rigging;

public class BoostPad : MonoBehaviour, ICollidable
{
    private bool _hasContact;
    private bool _isBoosting;
    private PlayerHandling _playerHandling;
    private PlayerBoost _playerBoost;

    [Header("Force")]
    [SerializeField] private float _force = 10f;
    [SerializeField] private ForceMode _forceMode;
    private float _currentForce;
    [SerializeField] private AnimationCurve _alignmentMapping;


    [Header("Overtime")]
    [SerializeField] private float _durationForFullOvertime;
    [SerializeField] private float _overtimeDuration;
    [SerializeField] private AnimationCurve _overtimeForceDecline;
    private float _onPadTimer;
    private float _currentOvertimeDuration;
    private float _overtimeTimer;
    private bool _overtimeRunning;
    private float _overtimeForce;
    private Vector3 _overtimeDirection;

    public void TriggerEnter(GameObject caller)
    {
        _hasContact = true;
        _playerHandling = caller.GetComponentInParent<PlayerHandling>();
        _playerBoost = caller.GetComponentInParent<PlayerBoost>();
    }

    public void TriggerExit()
    {
        _hasContact = false;
    }

    private void Update()
    {
        bool wasBoosting = _isBoosting;
        _isBoosting = _hasContact && _playerHandling.IsGrounded;

        if (_isBoosting)
        {
            if (_overtimeRunning) StopOvertime();
            _onPadTimer += Time.deltaTime;
            Boost();
        }
        else if (wasBoosting)
            StopBoost();

        if (_overtimeRunning) OvertimeBoost();
    }

    private void Boost()
    {
        float dotProduct = Vector3.Dot(_playerHandling.transform.forward, transform.forward);
        float dotPercent = Utility.RemapNumber(dotProduct, -1f, 1f, 0, 1f);
        _currentForce = _force * _alignmentMapping.Evaluate(dotPercent);
        Vector3 direction = transform.forward;
        Vector3 force = direction * _currentForce;
        _playerBoost.SetBoost(force, _forceMode);
    }

    private void StopBoost()
    {
        _overtimeRunning = true;
        _overtimeForce = _currentForce;
        _overtimeDirection = _playerHandling.transform.forward;
        float percent = Mathf.Clamp01(Utility.RemapNumber(_onPadTimer, 0f, _durationForFullOvertime, 0f, 1f));
        _currentOvertimeDuration = percent * _overtimeDuration;
        _onPadTimer = 0;
        StartCoroutine(Overtime());
    }

    private void OvertimeBoost()
    {
        Vector3 direction = _overtimeDirection;
        float forceDeclined = _overtimeForce * _overtimeForceDecline.Evaluate(_overtimeTimer / _overtimeDuration);
        Vector3 force = direction * forceDeclined;
        _playerBoost.SetBoost(force, _forceMode);
    }

    private void StopOvertime()
    {
        StopCoroutine(Overtime());
        _overtimeRunning = false;
    }

    private IEnumerator Overtime()
    {
        while (_overtimeTimer < _currentOvertimeDuration)
        {
            _overtimeTimer += Time.deltaTime;
            yield return null;
        }
        _overtimeTimer = 0;
        _overtimeRunning = false;
        _playerBoost.StopBoost();
    }
}
