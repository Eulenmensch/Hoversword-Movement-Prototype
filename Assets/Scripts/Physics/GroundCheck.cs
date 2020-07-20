using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GroundCheck : MonoBehaviour
{
    [SerializeField] private LayerMask GroundMask;      //The layer mask that determines what counts as ground
    [SerializeField] private float GroundRayLength;     //How long the ray checking for ground is
    [SerializeField] private float MaxSlopeAngle;       //Up to which angle of the hit normal in relation to world up is considered as grounded
    [SerializeField] private DownDirectionSpace Space;  //Whether the ray is cast to world down or local down

    private enum DownDirectionSpace
    {
        Local,
        World
    }
    private Vector3 DownDirection;                      //The down direction in which the ray is cast

    //Sets the down direction depending on the specified Space
    private void SetDownDirection()
    {
        if ( Space == DownDirectionSpace.Local ) { DownDirection = -transform.up; }
        else if ( Space == DownDirectionSpace.World ) { DownDirection = Vector3.down; }
    }

    //Checks downwards for Ground
    public bool IsGrounded()
    {
        SetDownDirection();

        RaycastHit hit;
        bool ray = Physics.Raycast( transform.position, DownDirection, out hit, GroundRayLength, GroundMask );
        if ( ray && CheckMaxAngle( hit.normal, MaxSlopeAngle ) )
        {
            return true;
        }
        return false;
    }
    //overloaded function that also gives raycast hit info in an out parameter
    public bool IsGrounded(out RaycastHit _hit)
    {
        SetDownDirection();

        RaycastHit hit;
        bool ray = Physics.Raycast( transform.position, DownDirection, out hit, GroundRayLength, GroundMask );
        _hit = hit;
        if ( ray && CheckMaxAngle( hit.normal, MaxSlopeAngle ) )
        {
            return true;
        }
        return false;
    }
    //overloaded function that takes a ray origin position as an argument
    public bool IsGrounded(Vector3 _rayOrigin)
    {
        SetDownDirection();

        RaycastHit hit;
        bool ray = Physics.Raycast( _rayOrigin, DownDirection, out hit, GroundRayLength, GroundMask );
        if ( ray && CheckMaxAngle( hit.normal, MaxSlopeAngle ) )
        {
            return true;
        }
        return false;
    }
    //overloaded function that takes a ray origin position as an argument and gives raycast hit info in an out parameter
    public bool IsGrounded(Vector3 _rayOrigin, out RaycastHit _hit)
    {
        SetDownDirection();

        RaycastHit hit;
        bool ray = Physics.Raycast( _rayOrigin, DownDirection, out hit, GroundRayLength, GroundMask );
        _hit = hit;
        if ( ray && CheckMaxAngle( hit.normal, MaxSlopeAngle ) )
        {
            return true;
        }
        return false;
    }

    private bool CheckMaxAngle(Vector3 _normal, float _maxAngle)
    {
        float angle = Vector3.Angle( Vector3.up, _normal );
        if ( angle <= _maxAngle )
        {
            return true;
        }
        return false;
    }
}
