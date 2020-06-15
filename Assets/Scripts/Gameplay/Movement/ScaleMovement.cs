using DG.Tweening;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScaleMovement : MonoBehaviour
{
    //[SerializeField] private float _scaleFactor = 1f;
    [SerializeField] private Vector3 _scale = Vector3.one;
    [SerializeField] private bool _scaleRelative = true;
    [Space(10)]
    [SerializeField] private Ease _ease = Ease.Linear;
    [SerializeField] private float _duration = 1f;
    [SerializeField] private bool _scaleAtStart;
    [Space(10)]
    [SerializeField] private bool _isSpeedBased;
    [SerializeField] private float _speed = 1f;
    
    private Vector3 _initialScale;
    

    private void Start()
    {
        _initialScale = transform.localScale;
        if (_scaleAtStart)
        {
            Scale();
        }
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.J))
        {
            Scale();
        }
    }

    internal void Scale()
    {
        Vector3 newScale = _scaleRelative ?
            new Vector3(_initialScale.x * _scale.x, _initialScale.y * _scale.y, _initialScale.z * _scale.z) :
            _scale;
        transform.DOScale(newScale, _isSpeedBased ? _speed : _duration).SetSpeedBased(_isSpeedBased).SetEase(_ease);

        //DOTween.To(() => transform, x => _angle = x, _endAngle, _speed).SetSpeedBased().SetLoops(-1, LoopType.Yoyo).SetEase(ease);
    }
}
