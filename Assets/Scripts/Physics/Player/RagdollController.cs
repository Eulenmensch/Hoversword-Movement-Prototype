using UnityEngine;
using UnityEngine.InputSystem;

public class RagdollController : MonoBehaviour
{
    [SerializeField] float DeathForce = 200;
    [SerializeField] GameObject Character;
    private Collider[] Colliders;
    private Rigidbody[] Rigidbodies;
    private Rigidbody RB;

    [SerializeField] private bool _crashOnCollision;
    [SerializeField] private float _forceMin = 20f;
    [SerializeField] private float _forceMax = 40f;
    [SerializeField] private float _upMin = 0.65f;
    [SerializeField] private float _upMax = 1f;
    [SerializeField] private float _frontMin = 0.4f;
    [SerializeField] private float _frontMax = 0.8f;
    [SerializeField] private float _sumThresold = 1.6f;

    //[SerializeField] private float _frontalThreshold;
    //[SerializeField] private float _upThreshold;
    //[SerializeField] private float _forceThreshold;

    private void Start()
    {
        Rigidbodies = Character.GetComponentsInChildren<Rigidbody>();
        Colliders = Character.GetComponentsInChildren<Collider>();
        RB = GetComponent<Rigidbody>();
        SetRigidbodiesKinematic(true);
        SetCollidersEnabled(false);
    }

    public void Die(InputAction.CallbackContext context)
    {
        if (context.started)
        {
            Vector3 crashForce = (transform.forward + transform.up + RB.velocity) * DeathForce;
            RagdollCrash(crashForce);
        }
    }

    public void RagdollCrash(Vector3 _crashForce)
    {
        SetRigidbodiesKinematic(false);
        SetCollidersEnabled(true);
        Character.GetComponent<Animator>().enabled = false;
        foreach (var body in Rigidbodies)
        {
            //var forceMultiplier = Random.Range(0.8f, 1.2f);
            body.AddForce(_crashForce/* * forceMultiplier*/, ForceMode.VelocityChange);
        }
    }

    private void SetRigidbodiesKinematic(bool _isKinematic)
    {
        foreach (var body in Rigidbodies)
        {
            body.isKinematic = _isKinematic;
        }
    }

    private void SetCollidersEnabled(bool _isEnabled)
    {
        foreach (var collider in Colliders)
        {
            collider.enabled = _isEnabled;
        }
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (!_crashOnCollision)
            return;

        ContactPoint[] contactPoints = new ContactPoint[collision.contactCount];
        collision.GetContacts(contactPoints);

        foreach (var contactPoint in contactPoints)
        {
            DebugExtension.DebugPoint(contactPoint.point, Color.black, duration: 10f);
            Debug.DrawLine(contactPoint.point, contactPoint.point + contactPoint.normal, Color.grey, duration: 10f);
            //Debug.DrawLine(contactPoints[0].point, contactPoints[0].point + relativeVelocity, Color.red, duration: 10f);
        }

        var relativeVelocity = collision.relativeVelocity;
        var force = relativeVelocity.magnitude;
        var normal = contactPoints[0].normal;
        //var impulse = collision.impulse.magnitude;

        var dotFront = Vector3.Dot(normal, -transform.forward);
        var dotUp = Vector3.Dot(normal, transform.up);
        //print($"up: {dotUp}; front: {dotFront}; force: {force}; impulse: {impulse}");

        float forceWeight = Utility.RemapNumber(force, _forceMin, _forceMax, 0f, 1f);
        float upWeight = Utility.RemapNumberClamped(dotUp, _upMin, _upMax, 0, -1f);
        float frontWeight = Utility.RemapNumber(dotFront, _frontMin, _frontMax, 0f, 1f);
        float sum = forceWeight + upWeight + frontWeight;
        //print($"upW: {upWeight}; frontW: {frontWeight}; forceW: {forceWeight}; sum: {sum}");

        if (sum > _sumThresold)
        {
            print("CRASH");
            RagdollCrash(-relativeVelocity * 1.5f);
        }
    }
}