using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class PulseCoil : MonoBehaviour
{
    private Transform _target;

    [Header("Detection")]
    [SerializeField] private float _detectionRange = 10f;

    [Header("Loading")]
    [SerializeField] private float _loadDuration = 3f;
    private float _loadPerSecond;
    [SerializeField, ShowOnly] private bool _isInRange;
    private float _loadPercentage;

    [Header("Pulse")]
    [SerializeField] private GameObject _pulsePrefab;
    private float _pulseTimestamp;

    [Header("Visuals")]
    [SerializeField] private GameObject[] _rings;
    private Material[] _ringMats;
    [SerializeField, ColorUsage(true, true)] private Color _ringColorCool;
    [SerializeField, ColorUsage(true, true)] private Color _ringColorHot;
    [SerializeField, ColorUsage(true, true)] private Color _ringEmissionColorCool;
    [SerializeField, ColorUsage(true, true)] private Color _ringEmissionColorHot;

    private void Start()
    {
        _target = FindObjectOfType<Player>().transform;
        if (_target == null)
        {
            Debug.Log("Pulse Coil coudn't find player");
        }

        _loadPerSecond = 1f / _loadDuration;

        _ringMats = new Material[_rings.Length];
        for (int i = 0; i < _rings.Length; i++)
        {
            _ringMats[i] = _rings[i].GetComponent<Renderer>().material;
        }
    }

    private void Update()
    {
        if (_target == null)
            return;

        _isInRange = (Vector3.Distance(transform.position, _target.position) < _detectionRange);

        Load(_isInRange);
    }

    private void Load(bool positive)
    {
        float delta = _loadPerSecond * Time.deltaTime;
        _loadPercentage = positive ?
            Mathf.Clamp01(_loadPercentage + delta) :
            Mathf.Clamp01(_loadPercentage - delta);

        VisualizeLoad();

        if (_loadPercentage >= 1)
            Pulse();
    }

    private void VisualizeLoad()
    {
        Color color = Color.Lerp(_ringColorCool, _ringColorHot, _loadPercentage);
        Color emissionColor = Color.Lerp(_ringEmissionColorCool, _ringEmissionColorHot, _loadPercentage);
        foreach (var mat in _ringMats)
        {
            mat.SetColor("_Color", emissionColor);
            mat.SetColor("_EmissionColor", emissionColor);
        }
    }

    private void Pulse()
    {
        Debug.Log("Pulse");

        _loadPercentage = 0;
        _pulseTimestamp = Time.time;

        Instantiate(_pulsePrefab, transform.position, Quaternion.identity);
    }
}
