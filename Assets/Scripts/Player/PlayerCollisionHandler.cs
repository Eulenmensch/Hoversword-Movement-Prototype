using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class PlayerCollisionHandler : MonoBehaviour
{
    //[SerializeField]
    //private Collider _collider;
    [SerializeField]
    private LayerMask _collisionMask;

    [SerializeField]
    private float _cooldownDuration = 1f;

    private PlayerHealth _playerHealth;
    private PlayerEffects _playerEffects;

    private Dictionary<ICollidable, float> _collisionHistory = new Dictionary<ICollidable, float>();

    private void Awake()
    {
        _playerHealth = GetComponentInParent<PlayerHealth>();
        _playerEffects = transform.parent.GetComponentInChildren<PlayerEffects>();
    }

    private void OnTriggerEnter(Collider other)
    {
        UpdateHistory();

        // Checks if layer is in layer mask
        if (((1 << other.gameObject.layer) & _collisionMask) != 0)
        {
            ICollidable collidable = other.gameObject.GetComponentInParent<ICollidable>();
            if (collidable != null)
            {
                if (!_collisionHistory.ContainsKey(collidable))
                {
                    Debug.Log("Collided with: " + other.gameObject.name);

                    _collisionHistory.Add(collidable, Time.time);

                    CollisionInteraction collisionInteraction = collidable.Collide();
                    if (collisionInteraction.applyDamage) ProcessDamage(collisionInteraction);
                    if (collisionInteraction.teleport) Teleport(collisionInteraction.teleportTarget);
                }
            }
        }
    }

    private void Teleport(Vector3 target)
    {
        transform.parent.position = target;
    }

    private void ProcessDamage(CollisionInteraction damageData)
    {
        if (damageData.damage > 0)
        {
            _playerHealth.Damage(damageData.damage);
        }

        if (damageData.damageType == DamageType.Laser)
        {
            _playerEffects.LaserDamage();
        }

        if (damageData.damageDirectionType == DamageDirectionType.Velocity)
        {
            var rb = GetComponentInParent<Rigidbody>();
            float magnitude = rb.velocity.magnitude;
            Vector3 velocityDirection = rb.velocity.normalized;
            rb.AddForce(-velocityDirection * damageData.forceMagnitude * magnitude, ForceMode.Impulse);
            //rb.velocity = rb.velocity.normalized * rb.velocity.magnitude * 0.2f;
        }
    }

    private void UpdateHistory()
    {
        List<ICollidable> toDelete = new List<ICollidable>();
        foreach (var item in _collisionHistory)
        {
            if (item.Value + _cooldownDuration < Time.time)
            {
                toDelete.Add(item.Key);
            }
        }
        foreach (var item in toDelete)
        {
            _collisionHistory.Remove(item);
        }
        //toDelete.ForEach(k => _collisionHistory.Remove(k));
    }
}
