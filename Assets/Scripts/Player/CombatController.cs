using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.InputSystem;

public class CombatController : MonoBehaviour
{
    // References
    private HoverBoardControllerYoshi02 _hoverBoardController;
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
    public bool isAiming { get; private set; }
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
    private HashSet<IAttackable> _hitAttackableCache = new HashSet<IAttackable>();
    [SerializeField] private float _slashDuration;
    private float _slashTimestamp;

    [Header( "Slash Visuals" )]
    [SerializeField] private GameObject _boardExtension;
    [SerializeField] private TrailRenderer _boardTrail;

    [Header( "Collision" )]
    [SerializeField] private LayerMask _hitMask;
    private Collider[] _colliderCache;

    private int _attackID;


    //public Vector3 HitBoxSize;
    //public LayerMask EnemyLayers;

    private void Awake()
    {
        // Set references
        _hoverBoardController = GetComponent<HoverBoardControllerYoshi02>();
        _playerHealth = GetComponent<PlayerHealth>();
        if ( _flipColliderObject != null )
            _flipCollider = _flipColliderObject?.GetComponent<CapsuleCollider>();
        if ( _slashColliderObject != null )
            _slashCollider = _slashColliderObject?.GetComponent<CapsuleCollider>();
        _boardExtension.SetActive( false );
        _boardTrail.emitting = false;
    }

    private void Update()
    {
        // Process aiming input TODO: Do this with the new input system
        bool aimingInput = Input.GetAxis( "Left Trigger" ) > 0.15;

        if ( aimingInput && !isAiming && ( !_hoverBoardController.isGrounded || _aimOnGround ) )
        {
            print( "start" );
            StartAim();
        }

        if ( isAiming && ( ( _hoverBoardController.isGrounded && !_aimOnGround ) || !aimingInput ) )
        {
            print( "stop" );
            StopAim();
        }
    }

    void FixedUpdate()
    {
        if ( _attackState == AttackStates.Flip && _flipCollider != null )
        {
            //CheckCollision();
            _colliderCache = CapsuleCollisionCheck( _flipColliderObject.transform, _flipCollider );
            ProcessCollisions( AttackType.Flip );

            if ( _flipTimestamp + _flipDuration < Time.unscaledTime )
            {
                StopFlip();
            }
        }

        if ( _attackState == AttackStates.Slash )
        {
            //collision check
            //CheckForCollisions();
            _colliderCache = CapsuleCollisionCheck( _slashColliderObject.transform, _slashCollider );
            ProcessCollisions( AttackType.Slash );

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
        _boardAnimator.SetBool( "Aim", true );
        _boardExtension.SetActive( true );

        //_aimCharacterModel.isAiming = true;

        //_playerActionState = PlayerActionState.Aiming;
        //aimHUD.SetActive(true);


        //_timeTween?.Kill();
        //_timeTween = DOTween.To(() => _timescale, x => _timescale = x, _bulletTimescaleAiming, _bulletTimeAimingFadeInDuration)
        //    .SetEase(_bulletTimeAimingEaseIn).SetUpdate(true);
        TimeManager.Instance?.StartAim();
    }

    private void StopAim()
    {
        isAiming = false;
        _boardAnimator.SetBool( "Aim", false );
        _boardExtension.SetActive( false );


        //_aimCharacterModel.isAiming = false;

        //_playerActionState = PlayerActionState.None;
        //aimHUD.SetActive(false);
        //_timeTween?.Kill();
        //_timeTween = DOTween.To(() => _timescale, x => _timescale = x, 1f, _bulletTimeAimingFadeOutDuration)
        //    .SetEase(_bulletTimeAimingEaseOut).SetUpdate(true);
        TimeManager.Instance?.StopAim();
    }

    private void StartSlash()
    {
        _attackState = AttackStates.Slash;
        _slashTimestamp = Time.unscaledTime;
        _attackID++;
        _boardAnimator.SetBool( "Slash", true );
        _boardTrail.emitting = true;



        //TimeManager.Instance.stopFrame = true;

        //StartSlashVisualization();
        // Debug.Log("slash");
    }

    private void StopSlash()
    {
        _attackState = AttackStates.None;
        _boardAnimator.SetBool( "Slash", false );
        _boardTrail.emitting = false;

        //TimeManager.Instance.stopFrame = false;

        //StopSlashVisualization();
        // Debug.Log("stop slash");

        AttackableExit( ref _hitAttackableCache );
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
        _boardAnimator.SetBool( "Flip", false );
        AttackableExit( ref _hitAttackableCache );
    }

    private Collider[] CapsuleCollisionCheck(Transform colliderGameObject, CapsuleCollider collider)
    {
        // Getting the necessary positions for OverlapCapsule from capsule collider
        Vector3 capsuleDirection = collider.direction == 0 ?
            colliderGameObject.right : collider.direction == 1 ?
            colliderGameObject.transform.up : colliderGameObject.forward;

        Debug.DrawLine( colliderGameObject.position, colliderGameObject.position + capsuleDirection, Color.red, 3f );

        float height = collider.radius > collider.height ? collider.radius * 2f : collider.height;


        Vector3 center = colliderGameObject.TransformPoint( collider.center );

        //Quaternion rot = colliderGameObject.rotation;
        //center = rot * center;
        DebugExtension.DebugPoint( center, Color.red, 1f, 1f );

        Vector3 capsuleBottomPoint = center - capsuleDirection * ( height * 0.5f - collider.radius );
        Vector3 capsuleTopPoint = center + capsuleDirection * ( height * 0.5f - collider.radius );


        DebugExtension.DebugCapsule( capsuleBottomPoint - capsuleDirection * collider.radius, capsuleTopPoint + capsuleDirection * collider.radius,
            Color.black, collider.radius, 3f );

        //DebugExtension.DebugPoint(colliderGameObject.transform.position + collider.center, Color.green, 1f, 5f);
        //DebugExtension.DebugPoint(capsuleBottomPoint, Color.green);
        //DebugExtension.DebugPoint(capsuleTopPoint, Color.red);


        return Physics.OverlapCapsule( capsuleBottomPoint, capsuleTopPoint, collider.radius, _hitMask, QueryTriggerInteraction.Collide );
    }

    private void ProcessCollisions(AttackType _attackType)
    {
        if ( _colliderCache.Length > 0 )
        {
            foreach ( var item in _colliderCache )
            {
                IAttackable attackable = item.gameObject.GetComponentInParent<IAttackable>();
                if ( attackable != null )
                {
                    AttackInteraction attackInteraction = attackable.GetAttacked( _attackID, _attackType );
                    _playerHealth.AddHealth( attackInteraction.health );
                    _hitAttackableCache.Add( attackable );
                }
            }
        }
    }

    private void AttackableExit(ref HashSet<IAttackable> _attackables)
    {

        foreach ( var attackable in _attackables )
        {
            print( "attackable exit" );
            attackable.ExitAttacked();
        }
        _attackables.Clear();
    }

    //private void CheckCollision()
    //{
    //    // Getting the necessary positions for OverlapCapsule from capsule collider
    //    Vector3 capsuleDirection = _flipCollider.direction == 0 ? _flipColliderObject.transform.right : _flipCollider.direction == 1 ? _flipColliderObject.transform.up : _flipColliderObject.transform.forward;
    //    float height = _flipCollider.radius > _flipCollider.height ? _flipCollider.radius * 2f : _flipCollider.height;
    //    Vector3 capsuleBottomPoint = _flipColliderObject.transform.position + _flipCollider.center - capsuleDirection * (height * 0.5f - _flipCollider.radius);
    //    Vector3 capsuleTopPoint = _flipColliderObject.transform.position + _flipCollider.center + capsuleDirection * (height * 0.5f - _flipCollider.radius);
    //    //DebugExtension.DebugPoint(_collisionObject.transform.position + _collider.center, Color.green, 1f, 5f);
    //    //DebugExtension.DebugPoint( capsuleBottomPoint, Color.green );
    //    //DebugExtension.DebugPoint( capsuleTopPoint, Color.green );

    //    _colliderCache = Physics.OverlapCapsule(capsuleBottomPoint, capsuleTopPoint, _flipCollider.radius, _hitMask, QueryTriggerInteraction.Collide);
    //    if (_colliderCache.Length > 0)
    //    {
    //        foreach (var item in _colliderCache)
    //        {
    //            IAttackable attackable = item.gameObject.GetComponentInParent<IAttackable>();
    //            if (attackable != null)
    //            {
    //                AttackInteraction attackInteraction = attackable.GetAttacked();
    //                _playerHealth.AddHealth(attackInteraction.health);
    //            }
    //            Rigidbody rigidbody = item.gameObject.GetComponent<Rigidbody>();
    //            if (rigidbody != null)
    //            {
    //                RepellEnemies(rigidbody);
    //            }
    //        }
    //    }
    //}
}
