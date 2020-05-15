using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class CombatController : MonoBehaviour
{
    private PlayerHealth _playerHealth;

    [Header("Animators")]
    public Animator CharacterAnimator;
    public Animator BoardAnimator;

    [Header("Flip Attack")]
    [SerializeField] private GameObject _flipColliderObject;
    private CapsuleCollider _flipCollider;

    private bool _isFlipping;
    [SerializeField]
    private float _flipDuration;
    private float _flipTimestamp;

    private Collider[] _colliderCache;

    [SerializeField] private LayerMask _hitMask;


    //public Vector3 HitBoxSize;
    //public LayerMask EnemyLayers;

    private void Awake()
    {
        _playerHealth = GetComponent<PlayerHealth>();
        _flipCollider = _flipColliderObject.GetComponent<CapsuleCollider>();
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        if (_isFlipping)
        {
            CheckCollision();

            if (_flipTimestamp + _flipDuration < Time.time)
            {
                _isFlipping = false;
            }
        }
    }

    private void CheckCollision()
    {
        Vector3 capsuleDirection = _flipCollider.direction == 0 ? _flipColliderObject.transform.right : _flipCollider.direction == 1 ? _flipColliderObject.transform.up : _flipColliderObject.transform.forward;
        float height = _flipCollider.radius > _flipCollider.height ? _flipCollider.radius * 2f : _flipCollider.height;
        Vector3 capsuleBottomPoint = _flipColliderObject.transform.position + _flipCollider.center - capsuleDirection * (height * 0.5f - _flipCollider.radius);
        Vector3 capsuleTopPoint = _flipColliderObject.transform.position + _flipCollider.center + capsuleDirection * (height * 0.5f - _flipCollider.radius);

        //DebugExtension.DebugPoint(_collisionObject.transform.position + _collider.center, Color.green, 1f, 5f);
        DebugExtension.DebugPoint(capsuleBottomPoint, Color.green);
        DebugExtension.DebugPoint(capsuleTopPoint, Color.green);

        _colliderCache = Physics.OverlapCapsule(capsuleBottomPoint, capsuleTopPoint, _flipCollider.radius, _hitMask, QueryTriggerInteraction.Collide);
        if (_colliderCache.Length > 0)
        {
            foreach (var item in _colliderCache)
            {
                IAttackable attackable = item.gameObject.GetComponentInParent<IAttackable>();
                if (attackable != null)
                {
                    AttackInteraction attackInteraction = attackable.GetAttacked();
                    _playerHealth.AddHealth(attackInteraction.health);
                }
            }
        }
    }

    public void GetAttackInput(InputAction.CallbackContext context)
    {
        if (context.performed)
        {
            CharacterAnimator.SetTrigger("Jump");
            BoardAnimator.SetTrigger("Attack");

            _isFlipping = true;
            _flipTimestamp = Time.time;
        }
    }

    //private void OnDrawGizmosSelected()
    //{
    //    if (HitBox == null)
    //    {
    //        return;
    //    }
    //    Gizmos.DrawWireCube(HitBox.transform.position, HitBoxSize);
    //}
}
