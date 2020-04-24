using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;


[RequireComponent(typeof(Rigidbody))]
public class HoverBoardController : MonoBehaviour
{
    public float ForwardAccelleration;
    public float BackwardAccelleration;
    public float TurnForce;
    public float HoverForce;
    public float HoverHeight;
    public float CorrectiveTorqueForce;
    public GameObject[] HoverPoints;
    public LayerMask RayLayerMask;

    public float GroundedDistance;
    public float JumpForce;

    public Animator CharacterAnimator;

    private Rigidbody RigidbodyReference;
    private float CurrentThrust;
    private float CurrentTurnForce;

    private Vector2 InputVector;
    private bool IsCrouching;


    // Start is called before the first frame update
    void Start()
    {
        RigidbodyReference = GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void Update()
    {
        HandleMoveInput();
    }

    private void FixedUpdate()
    {
        Hover();
        ApplyMoveInput();
        DontFlipOver();
    }

    void Hover()
    {
        RaycastHit hit;
        foreach (var hoverPoint in HoverPoints)
        {
            if (Physics.Raycast(hoverPoint.transform.position, Vector3.down, out hit, HoverHeight, RayLayerMask))
            {
                RigidbodyReference.AddForceAtPosition(Vector3.up * (HoverForce * Mathf.Pow((1.0f - (hit.distance / HoverHeight)), 1.7f)), hoverPoint.transform.position);
                //RigidbodyReference.AddForceAtPosition(Vector3.up * (HoverForce / Mathf.Pow(hit.distance, HoverHeight)), hoverPoint.transform.position);
                //RigidbodyReference.AddForceAtPosition(transform.up * HoverForce * Mathf.Pow((HoverHeight / hit.distance), 1.5f), hoverPoint.transform.position);
            }
            // else
            // {
            //     if (transform.position.y > hoverPoint.transform.position.y)
            //     {
            //         RigidbodyReference.AddForceAtPosition(hoverPoint.transform.up * HoverForce, hoverPoint.transform.position);
            //     }
            //     else
            //     {
            //         RigidbodyReference.AddForceAtPosition(hoverPoint.transform.up * -HoverForce, hoverPoint.transform.position);
            //     }
            // }
        }
    }

    void DontFlipOver()
    {
        if (transform.localEulerAngles.z > 60.0f)
        {
            RigidbodyReference.AddRelativeTorque(transform.forward * CorrectiveTorqueForce, ForceMode.Force);
        }
        if (transform.localEulerAngles.z > 300.0f)
        {
            RigidbodyReference.AddRelativeTorque(-transform.forward * CorrectiveTorqueForce, ForceMode.Force);
        }
    }

    void HandleMoveInput()
    {
        CurrentThrust = 0.0f;
        float thrustInput = InputVector.y;
        if (thrustInput > 0.0f)
        {
            CurrentThrust = thrustInput * ForwardAccelleration;
        }
        else if (thrustInput < 0.0f)
        {
            CurrentThrust = thrustInput * BackwardAccelleration;
        }

        CurrentTurnForce = 0.0f;
        float turnInput = InputVector.x;
        CurrentTurnForce = turnInput * TurnForce;
    }

    void ApplyMoveInput()
    {
        if (CurrentThrust != 0)
        {
            RigidbodyReference.AddForce(transform.forward * CurrentThrust, ForceMode.Force);
        }

        if (CurrentTurnForce != 0)
        {
            RigidbodyReference.AddRelativeTorque(Vector3.up * CurrentTurnForce, ForceMode.Force);
        }
    }

    public void GetMoveInput(InputAction.CallbackContext context)
    {
        InputVector = context.ReadValue<Vector2>();
    }

    public void GetCrouchJumpInput(InputAction.CallbackContext context)
    {
        if (context.performed && !IsCrouching)
        {
            IsCrouching = true;
            CharacterAnimator.SetBool("IsCrouching", true);
        }
        else if (context.performed && IsCrouching)
        {
            IsCrouching = false;
            CharacterAnimator.SetBool("IsCrouching", false);
            if (IsGrounded())
            {
                Jump();
            }
        }
    }

    void Jump()
    {
        RigidbodyReference.AddForce(Vector3.up * JumpForce, ForceMode.Impulse);
    }

    bool IsGrounded()
    {
        return Physics.Raycast(transform.position, Vector3.down, GroundedDistance, RayLayerMask);
    }
}
