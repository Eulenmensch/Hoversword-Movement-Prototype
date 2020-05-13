using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Obstacle : MonoBehaviour, ICollidable
{
    [SerializeField]
    private bool _isActive = true;
    //public bool isActive { get => _isActive; set => _isActive = value; }

    [SerializeField]
    protected int _damage;
    [SerializeField]
    protected DamageType _damageType;

    [SerializeField]
    protected float _forceMagnitude;

    protected Collider _collider;

    protected virtual void Awake()
    {
        _collider = GetComponent<Collider>();
        _collider.enabled = _isActive;
    }

    public virtual DamageData Collide()
    {
        return new DamageData(_damage, _damageType, _forceMagnitude, false, Vector3.zero);
    }

    public void SetActive(bool value)
    {
        _isActive = value;
        _collider.enabled = value;
    }
}
