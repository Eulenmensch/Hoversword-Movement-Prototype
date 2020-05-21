using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PointMovement : MonoBehaviour
{
    [SerializeField] float _speed = 1;
    [SerializeField] Ease ease = Ease.Linear;




    [SerializeField] private List<Transform> _points;
    [SerializeField] private int _startingPoint;
    private int _currentPoint;

    [SerializeField, Range(0, 1)] private float _startPercent;

    private void Start()
    {
        if (_points[_currentPoint] == null)
            return;

        //
        _currentPoint = _startingPoint;
        GetStartPosition();

        transform.position = GetStartPosition();
        MoveToNextPoint();
    }

    private Vector3 GetStartPosition()
    {
        return Vector3.Lerp(_points[_currentPoint].position, _points[GetNextPointIndex()].position, _startPercent);
    }

    private void MoveToNextPoint()
    {
        _currentPoint = GetNextPointIndex();

        transform.DOMove(_points[_currentPoint].position, _speed).SetSpeedBased().SetEase(ease).OnComplete(MoveToNextPoint);
    }

    private int GetNextPointIndex()
    {
        int nextPointIndex = _currentPoint + 1;
        if (nextPointIndex >= _points.Count)
            nextPointIndex = 0;
        return nextPointIndex;
    }

    private void OnValidate()
    {
        _currentPoint = _startingPoint;

        if (_currentPoint + 1 > _points.Count)
            return;
        if (_points[_currentPoint] == null)
            return;

        transform.position = GetStartPosition();
    }
}
