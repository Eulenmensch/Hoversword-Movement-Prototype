using UnityEngine;

[RequireComponent(typeof(Rigidbody))]
public class CustomCenterOfMass : MonoBehaviour
{
    public Transform CenterOfMassTransform
    {
        get { return centerOfMass; }
        private set { centerOfMass = value; }
    }
    [SerializeField] Transform centerOfMass;

    private Rigidbody RB;

    private void Start()
    {
        RB = GetComponent<Rigidbody>();
        SetCenterOfMass(centerOfMass.localPosition);
    }

    public void SetCenterOfMass(Vector3 _position)
    {
        RB.centerOfMass = _position;
    }

#if UNITY_EDITOR
    private void OnDrawGizmos()
    {
        Gizmos.color = Color.cyan;
        var centerOfMass = this.centerOfMass.position;
        Gizmos.DrawSphere(centerOfMass, 0.2f);
    }
#endif
}
