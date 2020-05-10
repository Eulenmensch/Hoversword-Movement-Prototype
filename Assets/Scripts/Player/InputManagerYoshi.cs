using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

[RequireComponent( typeof( HoverBoardControllerYoshi02 ) )]
public class InputManagerYoshi : MonoBehaviour
{
    private HoverBoardControllerYoshi02 ControllerYoshi02;
    private void Awake()
    {
        ControllerYoshi02 = GetComponent<HoverBoardControllerYoshi02>();
    }
    public void GetMoveInput(InputAction.CallbackContext context)
    {
        Vector2 inputVector = context.ReadValue<Vector2>();
        ControllerYoshi02.SetMoveInput( inputVector.y, inputVector.x );
    }
    public void GetAirControlInput(InputAction.CallbackContext context)
    {
        Vector2 inputVector = context.ReadValue<Vector2>();
        ControllerYoshi02.SetAirControlInput( inputVector.y, inputVector.x );
    }
}
