using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using UnityEngine;

public class DangerZone : MonoBehaviour, ICollidable, IReset
{
    public PlayerHealth _playerHealth { get; set; }

    //private DamageDealer _damageDealer;

    [Header("Loading")]
    [SerializeField, ShowOnly] private float _load;
    private float _lastLoad;
    [SerializeField] private float _loadDuration = 1f;
    [SerializeField] private float _deloadDuration = 1f;
    private bool _isLoading;

    [Header("Damage")]
    [SerializeField] private int _damage = 1;
    [SerializeField] private DamageTypes _damageType = DamageTypes.Laser;

    [Header("Visuals")]
    [SerializeField] private GameObject _partsHolder;
    private List<GameObject> _parts = new List<GameObject>();
    private Material[] _partMaterials;
    //[SerializeField, ColorUsage(true, true)] private Color _partColorCool;
    //[SerializeField, ColorUsage(true, true)] private Color _partColorHot;
    //[SerializeField, ColorUsage(true, true)] private Color _partEmissionColorCool;
    //[SerializeField, ColorUsage(true, true)] private Color _partEmissionColorHot;

    [SerializeField, GradientUsage(true)] private Gradient _partColorGradient;
    [SerializeField, GradientUsage(true)] private Gradient _partEmissionGradient;

    private void Awake()
    {
        //_damageDealer = GetComponent<DamageDealer>();
        //_damageDealer.isActive = false;

        foreach (Transform part in _partsHolder.transform)
            _parts.Add(part.gameObject);

        _partMaterials = new Material[_parts.Count];
        for (int i = 0; i < _parts.Count; i++)
            _partMaterials[i] = _parts[i].GetComponent<Renderer>().material;

        VisualizeLoad();
    }

    private void Update()
    {
        if (!_isLoading && _load == 0)
            return;

        float loadDelta = _isLoading ? Time.deltaTime / _loadDuration : -(Time.deltaTime / _deloadDuration);
        _load = Mathf.Clamp01(_load + loadDelta);

        if (_isLoading && _load >= 1 && _playerHealth != null)
            _playerHealth.Damage(_damage, _damageType);

        VisualizeLoad();
    }

    private void VisualizeLoad()
    {
        Color color = _partColorGradient.Evaluate(_load);
        Color emissionColor = _partEmissionGradient.Evaluate(_load);
        foreach (var mat in _partMaterials)
        {
            mat.SetColor("_Color", emissionColor);
            mat.SetColor("_EmissionColor", emissionColor);
        }
    }

    public void TriggerEnter(GameObject caller)
    {
        _playerHealth = caller.GetComponentInParent<PlayerHealth>();
        _isLoading = true;
    }

    public void TriggerExit()
    {
        _isLoading = false;
    }

    public void Reset()
    {
        _load = 0;
        _isLoading = false;
        VisualizeLoad();
    }
}
