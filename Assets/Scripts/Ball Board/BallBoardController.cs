using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using DG.Tweening;

public class BallBoardController : MonoBehaviour
{
    public float Speed;
    public float TurnSpeed;
    public GameObject Board;

    Vector2 InputVector;
    Vector2 rotatedInputVector;
    float cameraAngle;
    Rigidbody RigidbodyRef;
    // Start is called before the first frame update
    void Start()
    {
        RigidbodyRef = GetComponent<Rigidbody>();
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        RotateMoveInputToCameraForward();
        Move();
        MoveBoard();
        //Rotate();
    }

    void Move()
    {
        Vector3 inputForce = new Vector3(rotatedInputVector.x, 0.0f, rotatedInputVector.y);
        RigidbodyRef.AddForce(inputForce * Speed, ForceMode.Force);
    }

    void Rotate()
    {

        Vector3 inputTorque = Vector3.up * InputVector.x;
        RigidbodyRef.AddRelativeTorque(inputTorque * TurnSpeed, ForceMode.Force);
    }

    void MoveBoard()
    {
        Board.transform.position = transform.position;
        Vector3 BoardLookRotation = Quaternion.LookRotation(-RigidbodyRef.velocity, Vector3.up).eulerAngles;
        Board.transform.DORotate(BoardLookRotation, 0.3f, RotateMode.Fast).SetEase(Ease.OutCirc);
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
    }
}
