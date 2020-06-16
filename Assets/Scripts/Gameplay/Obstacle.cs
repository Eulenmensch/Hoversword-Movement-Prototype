using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[SelectionBase]
public abstract class Obstacle : MonoBehaviour, ICollidable, IShutOff
{
    [SerializeField] protected bool _isActive = true;
    //public bool isActive { get => _isActive; set => _isActive = value; }

    [Header("Collision Interaction")]
    [SerializeField] protected bool _applyDamage;
    [SerializeField] protected int _damage;
    [SerializeField] protected DamageType _damageType;
    [SerializeField] protected float _forceMagnitude;
    [SerializeField] protected DamageDirectionType _damageDirectionType;
    [SerializeField] protected bool _destroy;
    //[Space(10)]
    //[SerializeField] protected bool _applyHealth;
    //[SerializeField] protected int _health;

    protected Collider[] _colliders;

    public List<Machine> energySources { get; set; }

    protected virtual void Awake()
    {
        _colliders = GetComponentsInChildren<Collider>();
        foreach (var col in _colliders)
        {
            col.enabled = _isActive;
        }
    }

    public virtual CollisionInteraction Collide()
    {
        CollisionInteraction interactionData = new CollisionInteraction(true/*, false*/);
        if (_applyDamage) interactionData.SetDamage(true, _damage, _damageType, _forceMagnitude, _damageDirectionType);

        if (_destroy)
            Destroy(gameObject);

        //if (_applyHealth) interactionData.SetHealth(_health);
        return interactionData;
        //return new InteractionData(_damage, _damageType, _forceMagnitude, _damageDirectionType);
    }

    public virtual void SetActive(bool value)
    {
        _isActive = value;
        //foreach (var col in _colliders)
        //{
        //    col.enabled = _isActive;
        //}
    }

    public virtual void ShutOff(Machine machine)
    {

        //SetActive(false);
        if (energySources.Contains(machine))
        {
            energySources.Remove(machine);
        }
        else
        {
            Debug.Log("Energy Source wasn't register!");
        }

        if (energySources.Count == 0)
        {
            SetActive(false);
        }
    }

    public void Register(Machine machine)
    {
        if (energySources == null)
        {
            energySources = new List<Machine>();
        }

        if (!energySources.Contains(machine))
        {
            energySources.Add(machine);
            Debug.Log("Registered: " + energySources.Count);
        }
        else
        {
            Debug.Log("Energy Source tried to register twice!");
        }
    }
}
