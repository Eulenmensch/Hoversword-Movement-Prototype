using DG.Tweening;
using Dreamteck.Splines;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SplineMovement : MonoBehaviour, IMovement
{
    [SerializeField] private bool _moveOnStart;
    public bool IsMoving { get; set; }
    [SerializeField] private bool _isLooping;

    [SerializeField] float _speed = 1;
    private float _percentageSpeed;
    [SerializeField] Ease _ease = Ease.Linear;
    //[SerializeField] private bool _isLooping;
    [SerializeField] LoopType _loopType = LoopType.Yoyo;

    [SerializeField, Range(0, 1)] private float _startPercent;

    [SerializeField, ShowOnly] private float _percent;

    private SplineFollower _follower;

    void Awake()
    {
        _follower = GetComponent<SplineFollower>();
    }

    private void Start()
    {
        float length = _follower.CalculateLength();
        _percentageSpeed = _speed / length;

        _percent = _startPercent;
        SetFollower();

        if (_moveOnStart) Move();
    }

    public void Move()
    {
        if (_isLooping)
            DOTween.To(() => _percent, x => _percent = x, 1f, _percentageSpeed).SetSpeedBased().SetEase(_ease).OnComplete(StartLoopFromEnd);
        else
            DOTween.To(() => _percent, x => _percent = x, 1f, _percentageSpeed).SetSpeedBased().SetEase(_ease);
    }

    private void SetFollower()
    {
        _follower.SetPercent(_percent);
    }

    private void Update()
    {
        SetFollower();
    }

    private void StartLoopFromEnd()
    {
        switch (_loopType)
        {
            case LoopType.Restart:
                _percent = 0f;
                DOTween.To(() => _percent, x => _percent = x, 1f, _percentageSpeed).SetSpeedBased().SetLoops(-1, LoopType.Restart).SetEase(_ease);
                break;
            case LoopType.Yoyo:
                DOTween.To(() => _percent, x => _percent = x, 0f, _percentageSpeed).SetSpeedBased().SetLoops(-1, LoopType.Yoyo).SetEase(_ease);
                break;
            default:
                break;
        }

    }

    private void OnValidate()
    {
        if (_follower == null) _follower = GetComponent<SplineFollower>();
        _follower.startPosition = _startPercent;
        //SetFollower();
    }
}