using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(PlayerHandling), typeof(Rigidbody))]
public class PlayerTurn : MonoBehaviour
{
    public float TurnFriction
    {
        get { return turnFriction; }
        private set { turnFriction = value; }
    }

    [SerializeField] private float TurnForceMin;                    //The minimum force TurnForce can be
    [SerializeField] private float TurnForceMax;                    //The maximum force TurnForce can be
    [SerializeField] private float turnFriction;                    //The force that keeps the board from sliding sideways
    [SerializeField] private Transform TurnMotor;                   //The location where turn force is applied

    private float TurnForce;                                        //The force that makes the board turn

    private Rigidbody RB;
    private PlayerHandling Handling;

    private void Start()
    {
        RB = GetComponent<Rigidbody>();
        Handling = GetComponent<PlayerHandling>();
    }

    public void Turn(float _turnInput)
    {
        ScaleTurnForceWithSpeedInverse();
        ApplyTurnForce(_turnInput);
        //ApplySidewaysFriction();
    }

    private void ApplyTurnForce(float _turnInput)
    {
        //Make the Turn Input scale exponentially to get more of a carving feel when steering
        float scaledTurnInput = Mathf.Pow(_turnInput, 3);
        //Calculate turn force
        Vector3 turnForce = -transform.right * TurnForce * scaledTurnInput;
        //Apply calculated turn force to the rigidbody at the turn motor position
        RB.AddForceAtPosition(turnForce, TurnMotor.position, ForceMode.Acceleration);
    }

    private void ApplySidewaysFriction()
    {
        float sidewaysSpeed = Vector3.Dot(RB.velocity, -transform.right);
        RB.AddForce(transform.right * sidewaysSpeed * turnFriction, ForceMode.Acceleration);
    }

    private void ScaleTurnForceWithSpeedInverse()
    {
        TurnForce = TurnForceMax - ((TurnForceMax - TurnForceMin) * (RB.velocity.magnitude / Handling.MaxSpeed));
    }
}
