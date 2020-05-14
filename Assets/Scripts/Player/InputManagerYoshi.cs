﻿using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.Events;

[RequireComponent( typeof( HoverBoardControllerYoshi02 ) )]
public class InputManagerYoshi : MonoBehaviour
{
    [SerializeField] UnityEvent OnJump;
    [SerializeField] UnityEvent OnLeftSideShift;
    [SerializeField] UnityEvent OnRightSideShift;
    private HoverBoardControllerYoshi02 ControllerYoshi02;
    private bool IsCarving;

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

    public void GetCrouchJumpInput(InputAction.CallbackContext context)
    {
        if ( context.performed )
        {
            OnJump.Invoke();
        }
    }
    public void GetLeftSideShiftInput(InputAction.CallbackContext context)
    {
        if ( context.performed )
        {
            OnLeftSideShift.Invoke();
        }
    }
    public void GetRightSideShiftInput(InputAction.CallbackContext context)
    {
        if ( context.performed )
        {
            OnRightSideShift.Invoke();
        }
    }


    public void GetCarveInput(InputAction.CallbackContext context)
    {
        if ( context.performed && !IsCarving )
        {
            IsCarving = true;
            ControllerYoshi02.SetCarveInput( IsCarving );
        }
        else if ( context.performed && IsCarving )
        {
            IsCarving = false;
            ControllerYoshi02.SetCarveInput( IsCarving );
        }
    }
}
