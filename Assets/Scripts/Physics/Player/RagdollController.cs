using UnityEngine;
using UnityEngine.InputSystem;

public class RagdollController : MonoBehaviour
{
    [SerializeField] float DeathForce = 200;
    [SerializeField] GameObject Character;
    private Collider[] Colliders;
    private Rigidbody[] Rigidbodies;
    private Rigidbody RB;

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
            var forceMultiplier = Random.Range(-2f, 5f);
            body.AddForce(_crashForce * forceMultiplier, ForceMode.VelocityChange);
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
}