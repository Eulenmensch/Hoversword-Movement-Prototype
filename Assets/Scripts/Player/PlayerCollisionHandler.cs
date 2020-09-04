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
    private PlayerCheckpointResetter _playerCheckpointResetter;
    //private PlayerEffects _playerEffects;

    //private Dictionary<ICollidable, float> _collisionHistory = new Dictionary<ICollidable, float>();

    private void Awake()
    {
        _playerHealth = GetComponentInParent<PlayerHealth>();
        _playerCheckpointResetter = GetComponentInParent<PlayerCheckpointResetter>();
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
            CheckForCheckpoint(gO);
            CheckForSceneLoading(gO);
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (((1 << other.gameObject.layer) & _collisionMask) != 0)
        {
            ICollidable collidable = other.gameObject.GetComponentInParent<ICollidable>();
            if (collidable != null)
                collidable.TriggerExit();
        }
    }

    private void CheckForCollision(GameObject target)
    {
        ICollidable collidable = target.GetComponentInParent<ICollidable>();
        if (collidable != null)
            collidable.TriggerEnter(gameObject);
    }

    private void CheckForHealthGain(GameObject target)
    {
        IGiveHealth giveHealth = target.GetComponentInParent<IGiveHealth>();
        if (giveHealth != null)
            _playerHealth.HealthGain(giveHealth.GiveHealth(false));
    }

    private void CheckForDamage(GameObject target)
    {
        IDealDamage dealDamage = target.GetComponentInParent<IDealDamage>();
        if (dealDamage != null)
        {
            (int damage, DamageTypes damageType) = dealDamage.DealDamage();
            if (damage > 0)
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

    private void CheckForCheckpoint(GameObject target)
    {
        Checkpoint checkpoint = target.GetComponentInParent<Checkpoint>();
        if (checkpoint != null)
        {
            _playerCheckpointResetter.SetCheckpoint(checkpoint);
        }
    }

    private void CheckForSceneLoading(GameObject target)
    {
        SceneLoading sceneLoading = target.GetComponentInParent<SceneLoading>();
        if (sceneLoading != null)
        {
            if (sceneLoading.IsActive)
            {
                SceneHandler.Instance?.LoadScenes(sceneLoading.ScenesToLoad);
                SceneHandler.Instance?.SetLight(sceneLoading.ActivateDirectionalLight);
            }
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
}
