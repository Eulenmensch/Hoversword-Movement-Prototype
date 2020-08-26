using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class RagdollController : MonoBehaviour, IReset
{
    [Header( "References" )]
    [SerializeField] private GameObject _character;
    private Collider[] _characterColliders;
    private Rigidbody[] _characterRigidbodies;
    private Dictionary<Transform, Vector3> _resetPositions;
    private Dictionary<Transform, Quaternion> _resetRotations;
    private Animator _characterAnimator;
    [SerializeField] private GameObject _board;
    private Collider _boardCollider;
    private Rigidbody _boardRigidbody;
    private Animator _boardAnimator;

    private Rigidbody RB;

    [Header( "Crashing" )]
    [SerializeField] private bool _crashOnCollision;
    [SerializeField] private float _forceMin = 20f;
    [SerializeField] private float _forceMax = 40f;
    [SerializeField] private float _upMin = 0.65f;
    [SerializeField] private float _upMax = 1f;
    [SerializeField] private float _frontMin = 0.4f;
    [SerializeField] private float _frontMax = 0.8f;
    [SerializeField] private float _sumThresold = 1.6f;
    [SerializeField] private LayerMask _collisionMask;

    [Header( "Ragdolling" )]
    [SerializeField] private float DeathForce = 200;

    private PlayerHealth _playerHealth;



    //[SerializeField] private float _frontalThreshold;
    //[SerializeField] private float _upThreshold;
    //[SerializeField] private float _forceThreshold;

    private void Start()
    {
        _playerHealth = GetComponent<PlayerHealth>();
        RB = GetComponent<Rigidbody>();

        _characterRigidbodies = _character.GetComponentsInChildren<Rigidbody>();
        _characterColliders = _character.GetComponentsInChildren<Collider>();
        _boardRigidbody = _board.GetComponent<Rigidbody>();
        _boardCollider = _board.GetComponent<Collider>();

        _characterAnimator = _character.GetComponent<Animator>();
        _boardAnimator = _board.GetComponent<Animator>();

        SetRigidbodiesKinematic( true );
        SetCollidersEnabled( false );

        SetStartingPositions();
    }

    private void SetStartingPositions()
    {
        _resetPositions = new Dictionary<Transform, Vector3>();
        _resetRotations = new Dictionary<Transform, Quaternion>();
        foreach ( var item in _characterRigidbodies )
        {
            _resetPositions[item.transform] = item.transform.localPosition;
            _resetRotations[item.transform] = item.transform.localRotation;
        }
        _resetPositions[_boardRigidbody.transform] = _boardRigidbody.transform.localPosition;
        _resetRotations[_boardRigidbody.transform] = _board.transform.localRotation;
    }

    private void ResetPositions()
    {
        foreach ( var pair in _resetPositions )
        {
            pair.Key.localPosition = pair.Value;
            pair.Key.localRotation = _resetRotations[pair.Key];
        }
    }

    public void Die(InputAction.CallbackContext context)
    {
        if ( context.started )
        {
            Vector3 crashForce = ( transform.forward + transform.up + RB.velocity ) * DeathForce;
            RagdollCrash( crashForce );
        }
    }

    public void RagdollCrash() => RagdollCrash( RB.velocity );

    public void RagdollCrash(Vector3 _crashForce)
    {
        SetRigidbodiesKinematic( false );
        SetCollidersEnabled( true );
        _characterAnimator.enabled = false;
        _boardAnimator.enabled = false;
        foreach ( var body in _characterRigidbodies )
        {
            //var forceMultiplier = Random.Range(0.8f, 1.2f);
            body.AddForce( _crashForce/* * forceMultiplier*/, ForceMode.VelocityChange );
        }
        _boardRigidbody.AddForce( _crashForce/* * forceMultiplier*/, ForceMode.VelocityChange );
    }

    private void SetRigidbodiesKinematic(bool _isKinematic)
    {
        foreach ( var body in _characterRigidbodies )
        {
            body.isKinematic = _isKinematic;
        }
        _boardRigidbody.isKinematic = _isKinematic;
    }

    private void SetCollidersEnabled(bool _isEnabled)
    {
        foreach ( var collider in _characterColliders )
        {
            collider.enabled = _isEnabled;
        }
        _boardCollider.enabled = _isEnabled;
    }

    private void OnCollisionEnter(Collision collision)
    {
        if ( !_crashOnCollision )
            return;

        if ( ( ( 1 << collision.gameObject.layer ) & _collisionMask ) == 0 )
            return;

        ContactPoint[] contactPoints = new ContactPoint[collision.contactCount];
        collision.GetContacts( contactPoints );

        foreach ( var contactPoint in contactPoints )
        {
            DebugExtension.DebugPoint( contactPoint.point, Color.black, duration: 10f );
            Debug.DrawLine( contactPoint.point, contactPoint.point + contactPoint.normal, Color.grey, duration: 10f );
            //Debug.DrawLine(contactPoints[0].point, contactPoints[0].point + relativeVelocity, Color.red, duration: 10f);
        }

        var relativeVelocity = collision.relativeVelocity;
        var force = relativeVelocity.magnitude;
        var normal = contactPoints[0].normal;
        //var impulse = collision.impulse.magnitude;

        var dotFront = Vector3.Dot( normal, -transform.forward );
        var dotUp = Vector3.Dot( normal, transform.up );
        //print($"up: {dotUp}; front: {dotFront}; force: {force}; impulse: {impulse}");

        float forceWeight = Utility.RemapNumberClamped( force, _forceMin, _forceMax, 0f, 1f );
        float upWeight = Utility.RemapNumberClamped( dotUp, _upMin, _upMax, 0, -1f );
        float frontWeight = Utility.RemapNumber( dotFront, _frontMin, _frontMax, 0f, 1f );
        float sum = forceWeight + upWeight + frontWeight;
        //print($"upW: {upWeight}; frontW: {frontWeight}; forceW: {forceWeight}; sum: {sum}");

        if ( sum > _sumThresold )
        {
            Crash( -relativeVelocity );
        }
    }

    private void Crash(Vector3 crashForce)
    {
        RagdollCrash( crashForce * 1.5f );
        _playerHealth.Damage( 1000, DamageTypes.Default );
    }

    public void Reset()
    {
        // Reset Animators and Rigid & so on

        SetRigidbodiesKinematic( true );
        SetCollidersEnabled( false );

        _characterAnimator.enabled = true;
        _boardAnimator.enabled = true;

        ResetPositions();
    }
}