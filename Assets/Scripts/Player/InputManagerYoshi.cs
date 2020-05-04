using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class InputManagerYoshi : Singleton<InputManagerYoshi>
{
    [HideInInspector] public float Thrust;
    [HideInInspector] public float Turn;
    public void GetMoveInput(InputAction.CallbackContext context)
    {
        Vector2 inputVector = context.ReadValue<Vector2>();
        Thrust = inputVector.y;
        Turn = inputVector.x;
    }
}
