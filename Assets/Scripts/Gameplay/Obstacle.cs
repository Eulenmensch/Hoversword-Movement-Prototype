using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[SelectionBase]
public abstract class Obstacle : MonoBehaviour, ICollidable, IShutOff
{
    [Header("Obstacle")]
    [SerializeField] protected bool _isActive = true;
    //public bool isActive { get => _isActive; set => _isActive = value; }

    [SerializeField] protected int _damage;
    [SerializeField] protected DamageType _damageType;

    [SerializeField] protected float _forceMagnitude;

    [SerializeField] protected DamageDirectionType _damageDirectionType;

    protected Collider[] _colliders;

    protected virtual void Awake()
    {
        _colliders = GetComponentsInChildren<Collider>();
        foreach (var col in _colliders)
        {
            col.enabled = _isActive;
        }
    }

    public virtual DamageData Collide()
    {
        return new DamageData(_damage, _damageType, _forceMagnitude, _damageDirectionType);
    }

    public virtual void SetActive(bool value)
    {
        _isActive = value;
        //foreach (var col in _colliders)
        //{
        //    col.enabled = _isActive;
        //}
    }

    public virtual void ShutOff()
    {
        SetActive(false);
    }
}
