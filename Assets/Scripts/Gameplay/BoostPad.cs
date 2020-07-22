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

    //[Header("Force Rising")]
    //[SerializeField] private bool _useForceRising;
    //[SerializeField] private float _forceRiseDuration = 0.5f;
    //[SerializeField] private AnimationCurve _forceRise;
    //private float _forceTimer;
    private float _onPadTimer;

    [Header("Overtime")]
    [SerializeField] private float _durationForFullOvertime;
    [SerializeField] private float _overtimeDuration;
    private float _currentOvertimeDuration;
    [SerializeField] private AnimationCurve _overtimeForceDecline;
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

            //float forceRisen = _force;
            // Boost Timer
            //if (_useForceRising)
            //{
            //    bool rising = (_forceTimer < _forceRiseDuration);
            //    if (rising) _forceTimer += Time.deltaTime;
            //    float percent = _forceTimer / _forceRiseDuration;
            //    Debug.Log($"precent {percent}; rising: {rising}");
            //    forceRisen = rising ? _forceRise.Evaluate(percent) : _force;
            //}

            // Boost
            float dotProduct = Vector3.Dot(_playerHandling.transform.forward, transform.forward);
            float dotPercent = Utility.RemapNumber(dotProduct, -1f, 1f, 0, 1f);
            _currentForce = _force * _alignmentMapping.Evaluate(dotPercent);
            Vector3 direction = transform.forward;
            Vector3 force = direction * _currentForce;
            _playerBoost.SetBoost(force, _forceMode);
        }
        else if (wasBoosting)
        {
            // Stop Boost
            //_forceTimer = 0;

            _overtimeRunning = true;
            _overtimeForce = _currentForce;
            _overtimeDirection = _playerHandling.transform.forward;

            float percent = Mathf.Clamp01(Utility.RemapNumber(_onPadTimer, 0f, _durationForFullOvertime, 0f, 1f));

            _currentOvertimeDuration = percent * _overtimeDuration;
            _onPadTimer = 0;

            Debug.Log($"Current Overtime Duration: {_currentOvertimeDuration}");

            StartCoroutine(Overtime());
        }

        if (_overtimeRunning)
        {
            // TODO: Scale the overtime with how long player was on the pad

            // Overtime Boost
            Vector3 direction = _overtimeDirection;
            float forceDeclined = _overtimeForce * _overtimeForceDecline.Evaluate(_overtimeTimer / _overtimeDuration);
            Vector3 force = direction * forceDeclined;
            _playerBoost.SetBoost(force, _forceMode);
        }
    }

    private void StopOvertime()
    {
        StopCoroutine(Overtime());
        _overtimeRunning = false;
    }

    private IEnumerator Overtime()
    {
        while (_overtimeTimer < _overtimeDuration)
        {
            _overtimeTimer += Time.deltaTime;
            yield return null;
        }
        _overtimeTimer = 0;
        _overtimeRunning = false;
        _playerBoost.StopBoost();
    }
}
