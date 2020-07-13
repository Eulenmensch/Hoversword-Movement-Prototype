using DG.Tweening;
using Dreamteck.Splines;
using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SplineMovement : MonoBehaviour
{
    [SerializeField] float _speed = 1;
    private float _percentageSpeed;
    [SerializeField] Ease _ease = Ease.Linear;
    [SerializeField] LoopType _loopType = LoopType.Yoyo;

    //[SerializeField] private List<Transform> _points;
    //[SerializeField] private int _startingPoint;
    //private int _currentPoint;

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

        //float from = (float)_follower.clipFrom;
        //float to = (float)_follower.clipTo;
        //float from = 0;
        //float to = 1;

        _percent = _startPercent;
        SetFollower();

        DOTween.To(() => _percent, x => _percent = x, 1f, _percentageSpeed).SetSpeedBased().SetEase(_ease).OnComplete(StartLoopFromEnd);
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

    //private Vector3 GetStartPosition()
    //{
    //    return Vector3.Lerp(_points[_currentPoint].position, _points[GetNextPointIndex()].position, _startPercent);
    //}

    //private void MoveToNextPoint()
    //{
    //    _currentPoint = GetNextPointIndex();

    //    transform.DOMove(_points[_currentPoint].position, _speed).SetSpeedBased().SetEase(ease).OnComplete(MoveToNextPoint);
    //}

    //private int GetNextPointIndex()
    //{
    //    int nextPointIndex = _currentPoint + 1;
    //    if (nextPointIndex >= _points.Count)
    //        nextPointIndex = 0;
    //    return nextPointIndex;
    //}
    private void OnValidate()
    {
        if (_follower == null) _follower = GetComponent<SplineFollower>();
        _follower.startPosition = _startPercent;
        //SetFollower();

    }

    //private void OnValidate()
    //{
    //    _currentPoint = _startingPoint;

    //    if (_currentPoint + 1 > _points.Count)
    //        return;
    //    if (_points[_currentPoint] == null)
    //        return;

    //    transform.position = GetStartPosition();
    //}
}