using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent( typeof( Rigidbody ) )]
public class QuadraticDrag : MonoBehaviour
{
    public float Drag;                              //Quadratic force applied counter the board's velocity
    [SerializeField] private float AngularDrag;     //Quadratic force applied counter the board's angular velocity

    private Rigidbody RB;                           //A reference to the rigidbody

    private void Start()
    {
        RB = GetComponent<Rigidbody>();
    }

    private void FixedUpdate()
    {
        ApplyQuadraticDrag();
    }

    private void ApplyQuadraticDrag()
    {
        //Apply translational drag
        RB.AddForce( -Drag * RB.velocity.normalized * RB.velocity.sqrMagnitude, ForceMode.Acceleration );
        //Apply rotational drag
        RB.AddTorque( -AngularDrag * RB.angularVelocity.normalized * RB.angularVelocity.sqrMagnitude, ForceMode.Acceleration );
    }
}
