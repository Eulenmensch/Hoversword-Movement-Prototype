using UnityEngine;

public class CollisionSparkHandler : MonoBehaviour
{
    [SerializeField] private Transform collisionTransform;

    private void OnCollisionEnter(Collision other)
    {
        PlayerEvents.Instance.StartWallContact();
    }
    private void OnCollisionStay(Collision other)
    {
        if (other != null)
        {
            ContactPoint contactPoint = other.contacts[0];
            if (other.contacts.Length != 0)
            {
                collisionTransform.position = contactPoint.point;
                collisionTransform.rotation = Quaternion.LookRotation(contactPoint.normal, Vector3.up);
                PlayerEvents.Instance?.UpdateWallConcact(collisionTransform);
            }
        }
    }
    private void OnCollisionExit(Collision other)
    {
        PlayerEvents.Instance.StopWallContact();
    }
}