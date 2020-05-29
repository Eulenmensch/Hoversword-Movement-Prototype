using UnityEngine;

[RequireComponent( typeof( Rigidbody ) )]
public class CustomCenterOfMass : MonoBehaviour
{
    [SerializeField] Transform CenterOfMass;

    private Rigidbody RB;

    private void Start()
    {
        RB = GetComponent<Rigidbody>();
        RB.centerOfMass = CenterOfMass.localPosition;
    }

#if UNITY_EDITOR
    private void OnDrawGizmos()
    {
        Gizmos.color = Color.cyan;
        var centerOfMass = CenterOfMass.position;
        Gizmos.DrawSphere( centerOfMass, 0.2f );
    }
#endif
}
