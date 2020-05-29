using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent( typeof( Rigidbody ) )]
public class CustomGravity : MonoBehaviour
{
    [SerializeField] private float GroundGravity;       //The magnitude of the gravity affecting the body while grounded
    [SerializeField] private float AirGravity;          //The magnitude of the gravity affecting the body while airborne

    private Rigidbody RB;                               //A reference to the object's rigidbody
    private float CustomGravityMultiplier;              //How much the normalized gravity is multiplied by
    private GroundCheck GroundCheck;                    //A reference to the object's GroundCheck component

    private void Start()
    {
        RB = GetComponent<Rigidbody>();
        GroundCheck = GetComponent<GroundCheck>();

        RB.useGravity = false;
    }

    private void FixedUpdate()
    {
        SetCustomGravity();
        ApplyCustomGravity();
    }

    private void ApplyCustomGravity()
    {
        //Add a mass independent force in the direction of the global physics gravity multiplied by a editor defined value
        RB.AddForce( Physics.gravity.normalized * CustomGravityMultiplier, ForceMode.Acceleration );
    }

    private void SetCustomGravity()
    {
        //if the object has a ground check component
        if ( GroundCheck != null )
        {
            if ( GroundCheck.IsGrounded() )
            {
                CustomGravityMultiplier = GroundGravity;
            }
            else if ( !GroundCheck.IsGrounded() )
            {
                CustomGravityMultiplier = AirGravity;
            }
        }
        else
        {
            CustomGravityMultiplier = GroundGravity;
        }
    }
}
