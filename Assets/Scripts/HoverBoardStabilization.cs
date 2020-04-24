using System;
using System.Net.NetworkInformation;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using DG.Tweening;

public class HoverBoardStabilization : MonoBehaviour
{
    public Transform[] Stabilizers;
    public LayerMask Layers;
    public float Speed;
    public float RotationSpeed;
    public float UpForce;
    public float powerof;
    public float gravity;

    Rigidbody RigidbodyRef;
    Vector2 InputVector;
    Vector2 rotatedInputVector;
    float cameraAngle;

    Vector3 GravityDirection;

    // Start is called before the first frame update
    void Start()
    {
        RigidbodyRef = GetComponent<Rigidbody>();
        Physics.gravity = Vector3.down * gravity;
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        Stabilize();
        //SetRotationToMoveDirection();
        RotateMoveInputToCameraForward();
        Move();
        Rotate();
        //RotateGravity();
        Debug.DrawRay(transform.position + (Vector3.up * 0.1f), Physics.gravity.normalized, Color.cyan);
    }

    void Stabilize()
    {
        foreach (var stabilizer in Stabilizers)
        {
            RaycastHit hit;
            Physics.SphereCast(stabilizer.position, stabilizer.localScale.x, Physics.gravity.normalized, out hit, Mathf.Infinity, Layers);
            Vector3 groundDistance = hit.point - stabilizer.position;
            Vector3 force = transform.up * (UpForce / Mathf.Pow(groundDistance.magnitude, powerof));
            RigidbodyRef.AddForceAtPosition(force, stabilizer.position, ForceMode.Force);
            GravityDirection += hit.normal;
        }
        // Physics.gravity = -gravity * (GravityDirection / 4).normalized;
        // if (Physics.gravity.magnitude <= 0.1f)
        // {
        //     Physics.gravity = gravity * Vector3.down;
        //     Debug.Log("beep");
        // }
    }

    private void OnDrawGizmos()
    {
        foreach (var stabilizer in Stabilizers)
        {
            RaycastHit hit;
            Physics.SphereCast(stabilizer.position, stabilizer.localScale.x, Physics.gravity.normalized, out hit, Mathf.Infinity, Layers);
            Vector3 groundDistance = hit.point - stabilizer.position;
            Gizmos.DrawSphere(hit.point, 0.2f);
        }
    }

    void Move()
    {
        Vector3 inputForce = transform.forward * InputVector.y;
        RigidbodyRef.AddForce(-inputForce * Speed, ForceMode.Force);
    }

    void Rotate()
    {

        Vector3 inputTorque = transform.up * InputVector.x;
        RigidbodyRef.AddTorque(inputTorque * RotationSpeed, ForceMode.Force);
    }

    void RotateGravity()
    {
        GravityDirection = Vector3.zero;
        foreach (var stabilizer in Stabilizers)
        {
            RaycastHit hit;
            Physics.SphereCast(stabilizer.position, stabilizer.localScale.x, Physics.gravity.normalized, out hit, Mathf.Infinity, Layers);
            GravityDirection += hit.normal;
        }
        GravityDirection = GravityDirection / 4f;
        Physics.gravity = gravity * GravityDirection;
    }

    public void GetMoveInput(InputAction.CallbackContext context)
    {
        InputVector = context.ReadValue<Vector2>();
    }
    void RotateMoveInputToCameraForward()
    {
        cameraAngle = (Camera.main.transform.rotation.eulerAngles.y) * Mathf.Deg2Rad;

        rotatedInputVector = new Vector2(
            InputVector.x * Mathf.Cos(-cameraAngle) - InputVector.y * Mathf.Sin(-cameraAngle),
            InputVector.x * Mathf.Sin(-cameraAngle) + InputVector.y * Mathf.Cos(-cameraAngle)
        );


        // HorizontalInput = rotatedInputVector.x;
        // VerticalInput = rotatedInputVector.y;
    }

    void SetRotationToMoveDirection()
    {
        Vector3 lookDirection = new Vector3(rotatedInputVector.x, 0.0f, rotatedInputVector.y);
        if (lookDirection.magnitude >= 0.1)
        {
            transform.DORotateQuaternion(Quaternion.LookRotation(-lookDirection, Vector3.up), 0.4f).SetEase(Ease.OutCirc);
            //transform.rotation = Quaternion.LookRotation(lookDirection, Vector3.up);
        }
    }
}
