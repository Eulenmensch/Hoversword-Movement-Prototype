using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PointMovement : MonoBehaviour
{
    [SerializeField] float _speed = 1;
    [SerializeField] Ease ease = Ease.Linear;


    [SerializeField] private List<Transform> _points;
    private int _currentPoint;

    private void Start()
    {
        if (_points[_currentPoint] == null)
            return;

        transform.position = _points[_currentPoint].position;
        MoveToNextPoint();
    }

    private void MoveToNextPoint()
    {
        _currentPoint++;
        if (_currentPoint >= _points.Count)
            _currentPoint = 0;

        transform.DOMove(_points[_currentPoint].position, _speed).SetSpeedBased().SetEase(ease).OnComplete(MoveToNextPoint);
    }

    private void OnValidate()
    {
        if (_points[_currentPoint] != null)
        {
            transform.position = _points[_currentPoint].position;
        }
    }
}
