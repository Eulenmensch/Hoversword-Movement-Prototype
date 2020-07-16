using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.InputSystem;

public class CombatController : MonoBehaviour
{
    // References
    private HoverBoardControllerYoshi02 _hoverBoardController;
    private PlayerHandling _handling;
    private PlayerHealth _playerHealth;

    [Header( "Animators" )]
    public Animator _characterAnimator;
    public Animator _boardAnimator;

    public enum AttackStates { None, Flip, Slash }
    [Header( "States" )]
    [SerializeField] private AttackStates _attackState = AttackStates.None;
    //public AttackStates attackState { get { return _attackState; } private set { _attackState = value; } }

    [Header( "Aiming" )]
    [SerializeField, ShowOnly] private bool _isAiming;
    public bool isAiming { get { return _isAiming; } private set { _isAiming = value; } }
    [SerializeField] private bool _aimOnGround;

    [Header( "Flip Attack" )]
    [SerializeField] private GameObject _flipColliderObject;
    private CapsuleCollider _flipCollider;

    //private bool _isFlipping;
    [SerializeField] private float _flipDuration;
    private float _flipTimestamp;

    [Header( "Slash" )]
    [SerializeField] private GameObject _slashColliderObject;
    private CapsuleCollider _slashCollider;

    [SerializeField] private float _slashDuration;
    private float _slashTimestamp;

    [Header( "Slash Visuals" )]
    [SerializeField] private GameObject _boardExtension;
    [SerializeField] private TrailRenderer _boardTrail;

    [Header( "Collision" )]
    [SerializeField] private LayerMask _hitMask;
    private Collider[] _colliderCache;
    //private HashSet<IAttackable> _hitAttackableCache = new HashSet<IAttackable>();

    private int _attackID;


    private void Awake()
    {
        // Set references
        _hoverBoardController = GetComponent<HoverBoardControllerYoshi02>();
        _handling = GetComponent<PlayerHandling>();
        _playerHealth = GetComponent<PlayerHealth>();
        if ( _flipColliderObject != null )
            _flipCollider = _flipColliderObject.GetComponent<CapsuleCollider>();
        if ( _slashColliderObject != null )
            _slashCollider = _slashColliderObject.GetComponent<CapsuleCollider>();

        // TODO: Visuals
        _boardExtension.SetActive( false );
        _boardTrail.emitting = false;
    }

    private void Update()
    {
        // Process aiming input TODO: Do this with the new input system
        bool aimingInput = Input.GetAxis( "Left Trigger" ) > 0.15;

        if ( aimingInput && !isAiming && _attackState == AttackStates.None && ( !_handling.IsGrounded || _aimOnGround ) )
        {
            //print( "start" );
            StartAim();
        }

        if ( isAiming && ( ( _handling.IsGrounded && !_aimOnGround ) || !aimingInput ) )
        {
            // print( "stop" );
            StopAim();
        }
    }

    void FixedUpdate()
    {
        if ( _attackState == AttackStates.Flip && _flipCollider != null )
        {
            _colliderCache = CapsuleCollisionCheck( _flipColliderObject.transform, _flipCollider );
            ProcessCollisions( AttackTypes.Flip );

            if ( _flipTimestamp + _flipDuration < Time.unscaledTime )
            {
                StopFlip();
            }
        }

        if ( _attackState == AttackStates.Slash )
        {
            _colliderCache = CapsuleCollisionCheck( _slashColliderObject.transform, _slashCollider );
            ProcessCollisions( AttackTypes.Slash );

            if ( _slashTimestamp + _slashDuration < Time.unscaledTime )
            {
                StopSlash();
            }
        }
    }

    public void GetAttackInput(InputAction.CallbackContext context)
    {
        if ( context.performed )
        {
            if ( !isAiming && _attackState == AttackStates.None )
            {
                StartFlip();
            }

            if ( isAiming && _attackState == AttackStates.None )
            {
                StartSlash();
            }
        }
    }

    private void StartAim()
    {
        isAiming = true;
        TimeManager.Instance?.StartAim();
        _boardAnimator.SetBool( "Aim", true );
        _boardExtension.SetActive( true );
    }

    private void StopAim()
    {
        isAiming = false;
        TimeManager.Instance?.StopAim();
        _boardAnimator.SetBool( "Aim", false );
        _boardExtension.SetActive( false );
    }

    private void StartSlash()
    {
        _attackState = AttackStates.Slash;
        _slashTimestamp = Time.unscaledTime;
        _attackID++;
        _boardAnimator.SetBool( "Slash", true );
        _boardTrail.emitting = true;
    }

    private void StopSlash()
    {
        _attackState = AttackStates.None;
        //AttackableExit(ref _hitAttackableCache);
        _boardAnimator.SetBool( "Slash", false );
        _boardTrail.emitting = false;
    }

    private void StartFlip()
    {
        _attackState = AttackStates.Flip;
        _flipTimestamp = Time.unscaledTime;
        _attackID++;
        _boardAnimator.SetBool( "Flip", true );
    }

    private void StopFlip()
    {
        _attackState = AttackStates.None;
        //AttackableExit(ref _hitAttackableCache);
        _boardAnimator.SetBool( "Flip", false );
    }

    private void ProcessCollisions(AttackTypes _attackType)
    {
        if ( _colliderCache.Length > 0 )
        {
            foreach ( var item in _colliderCache )
            {
                CheckForAttack( _attackType, item.gameObject );
                CheckForHealth( item.gameObject );
            }
        }
    }

    private void CheckForAttack(AttackTypes _attackType, GameObject target)
    {
        // TODO: Gameobject hierarchy ?
        IAttackable attackable = target.GetComponentInParent<IAttackable>();
        if ( attackable != null )
        {
            // AttackInteraction attackInteraction = attackable.GetAttacked(_attackID, _attackType);
            attackable.GetAttacked( _attackID, _attackType );
            //_playerHealth.AddHealth(attackInteraction.health);
            //_hitAttackableCache.Add(attackable);
        }
    }

    private void CheckForHealth(GameObject target)
    {
        IGiveHealth giveHealth = target.GetComponentInParent<IGiveHealth>();
        if ( giveHealth != null )
            _playerHealth.HealthGain( giveHealth.GiveHealth( true ) );
    }

    private Collider[] CapsuleCollisionCheck(Transform colliderGameObject, CapsuleCollider collider)
    {
        Vector3 capsuleDirection;
        if ( collider.direction == 0 ) capsuleDirection = colliderGameObject.right;
        else if ( collider.direction == 1 ) capsuleDirection = colliderGameObject.transform.up;
        else capsuleDirection = colliderGameObject.forward;

        // Debug capsule direction
        // Debug.DrawLine(colliderGameObject.position, colliderGameObject.position + capsuleDirection * 10f, Color.red, 3f);

        float height = collider.radius > collider.height ? collider.radius * 2f : collider.height;
        Vector3 center = colliderGameObject.TransformPoint( collider.center );
        // Debug center
        // DebugExtension.DebugPoint(center, Color.red, 1f, 1f);

        Vector3 capsuleBottomPoint = center - capsuleDirection * ( height * 0.5f - collider.radius );
        Vector3 capsuleTopPoint = center + capsuleDirection * ( height * 0.5f - collider.radius );
        // Debug bottom and top point
        // DebugExtension.DebugPoint(capsuleBottomPoint, Color.green);
        // DebugExtension.DebugPoint(capsuleTopPoint, Color.red);
        // Debug capsule
        // DebugExtension.DebugCapsule(capsuleBottomPoint - capsuleDirection * collider.radius, capsuleTopPoint + capsuleDirection * collider.radius,
        //     Color.black, collider.radius, 3f);

        return Physics.OverlapCapsule( capsuleBottomPoint, capsuleTopPoint, collider.radius, _hitMask, QueryTriggerInteraction.Collide );
    }

    //private void AttackableExit(ref HashSet<IAttackable> _attackables)
    //{
    //    foreach (var attackable in _attackables)
    //    {
    //        print("attackable exit");
    //        attackable.ExitAttacked();
    //    }
    //    _attackables.Clear();
    //}
}
