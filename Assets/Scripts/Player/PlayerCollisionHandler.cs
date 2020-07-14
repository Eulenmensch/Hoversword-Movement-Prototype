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

    //[SerializeField]
    //private float _cooldownDuration = 1f;

    private PlayerHealth _playerHealth;
    //private PlayerEffects _playerEffects;

    //private Dictionary<ICollidable, float> _collisionHistory = new Dictionary<ICollidable, float>();

    private void Awake()
    {
        _playerHealth = GetComponentInParent<PlayerHealth>();
        //_playerEffects = transform.parent.GetComponentInChildren<PlayerEffects>();
    }

    private void OnTriggerEnter(Collider other)
    {
        //UpdateHistory();

        // Checks if layer is in layer mask
        if (((1 << other.gameObject.layer) & _collisionMask) != 0)
        {
            GameObject gO = other.gameObject;
            CheckForCollision(gO);
            CheckForHealthGain(gO);
            CheckForDamage(gO);
            CheckForPushing(gO);
        }
    }

    private void CheckForCollision(GameObject target)
    {
        ICollidable collidable = target.GetComponentInParent<ICollidable>();
        if (collidable != null)
            collidable.Collide();
        //{
        //    //if (!_collisionHistory.ContainsKey(collidable))
        //    //{
        //    //_collisionHistory.Add(collidable, Time.time);

        //    collidable.Collide();

        //    // CollisionInteraction collisionInteraction = collidable.Collide();
        //    //if (collisionInteraction.applyDamage) ProcessDamage(collisionInteraction);
        //    //if (collisionInteraction.teleport) Teleport(collisionInteraction.teleportTarget);
        //    //}
        //}
    }

    private void CheckForHealthGain(GameObject target)
    {
        IGiveHealth giveHealth = target.GetComponentInParent<IGiveHealth>();
        if (giveHealth != null)
            _playerHealth.AddHealth(giveHealth.GiveHealth(false));
    }

    private void CheckForDamage(GameObject target)
    {
        IDealDamage dealDamage = target.GetComponentInParent<IDealDamage>();
        if (dealDamage != null)
        {
            (int damage, DamageTypes damageType) = dealDamage.DealDamage();
            _playerHealth.Damage(damage, damageType);
        }
    }

    private void CheckForPushing(GameObject target)
    {
        IPush push = target.GetComponentInParent<IPush>();
        if (push != null)
        {
            (float pushStrength, PushTypes pushType) = push.Push();
            Push(pushStrength, pushType);
        }
    }

    // TODO: Refactor this somewhere
    private void Push(float pushStrength, PushTypes pushType)
    {
        if (pushType == PushTypes.Veloctiy)
        {
            var rb = GetComponentInParent<Rigidbody>();
            float magnitude = rb.velocity.magnitude;
            Vector3 velocityDirection = rb.velocity.normalized;
            rb.AddForce(-velocityDirection * pushStrength * magnitude, ForceMode.Impulse);
        }
    }

    //private void Teleport(Vector3 target)
    //{
    //    transform.parent.position = target;
    //}

    //private void ProcessDamage(CollisionInteraction damageData)
    //{
    //    if (damageData.damage > 0)
    //    {
    //        _playerHealth.AddHealth(damageData.damage);
    //    }

    //    //if (damageData.damageType == DamageType.Laser)
    //    //{
    //    //    _playerEffects.LaserDamage();
    //    //}

    //    if (damageData.damageDirectionType == DamageDirectionType.Velocity)
    //    {
    //        var rb = GetComponentInParent<Rigidbody>();
    //        float magnitude = rb.velocity.magnitude;
    //        Vector3 velocityDirection = rb.velocity.normalized;
    //        rb.AddForce(-velocityDirection * damageData.forceMagnitude * magnitude, ForceMode.Impulse);
    //        //rb.velocity = rb.velocity.normalized * rb.velocity.magnitude * 0.2f;
    //    }
    //}

    //private void UpdateHistory()
    //{
    //    List<ICollidable> toDelete = new List<ICollidable>();
    //    foreach (var item in _collisionHistory)
    //    {
    //        if (item.Value + _cooldownDuration < Time.time)
    //        {
    //            toDelete.Add(item.Key);
    //        }
    //    }
    //    foreach (var item in toDelete)
    //    {
    //        _collisionHistory.Remove(item);
    //    }
    //    //toDelete.ForEach(k => _collisionHistory.Remove(k));
    //}
}
