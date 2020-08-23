using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.Events;

[RequireComponent(typeof(HoverBoardControllerYoshi02))]
public class InputManagerYoshi : MonoBehaviour
{
    [SerializeField] UnityEvent OnJump;
    [SerializeField] UnityEvent OnLeftSideShift;
    [SerializeField] UnityEvent OnRightSideShift;
    [SerializeField] UnityEvent OnSeismicChargeFire;

    private HoverBoardControllerYoshi02 ControllerYoshi02;
    [SerializeField] ProjectileController Projectiles;
    [SerializeField] PlayerEngineFX EngineFX;
    [SerializeField] CharacterRigController RigController;
    private bool IsCarving;
    private bool IsCrouching;

    private void Awake()
    {
        ControllerYoshi02 = GetComponent<HoverBoardControllerYoshi02>();
    }
    public void GetMoveInput(InputAction.CallbackContext context)
    {
        Vector2 inputVector = context.ReadValue<Vector2>();
        ControllerYoshi02.SetMoveInput(inputVector.y, inputVector.x);
        EngineFX.SetMoveInput(inputVector.y, inputVector.x);
        // RigController.SetMoveInput( inputVector );
    }
    public void GetAirControlInput(InputAction.CallbackContext context)
    {
        Vector2 inputVector = context.ReadValue<Vector2>();
        ControllerYoshi02.SetAirControlInput(inputVector.y, inputVector.x);
    }

    public void GetCrouchJumpInput(InputAction.CallbackContext context) //FIXME: Refactor with a press and release modifier in the input asset
    {
        if (context.performed)
        {
            OnJump.Invoke();
        }
        if (context.started)
        {
            EngineFX.SetCrouching(true);
        }
        if (context.canceled)
        {
            EngineFX.SetCrouching(false);
        }
    }

    public void GetDashInput(InputAction.CallbackContext context)
    {
        if (context.started)
        {
            EngineFX.SetDashing(true);
        }
        if (context.performed)
        {
            ControllerYoshi02.SetDashInput(true);
        }
        if (context.canceled)
        {
            EngineFX.SetDashing(false);
            ControllerYoshi02.SetDashInput(false);
        }
    }

    public void GetLeftSideShiftInput(InputAction.CallbackContext context)
    {
        if (context.performed)
        {
            OnLeftSideShift.Invoke();
        }
    }
    public void GetRightSideShiftInput(InputAction.CallbackContext context)
    {
        if (context.performed)
        {
            OnRightSideShift.Invoke();
        }
    }

    public void GetSeismicChargeInput(InputAction.CallbackContext context)
    {
        if (context.started)
        {
            Projectiles.SetPreviewing(true);
        }
        else if (context.canceled)
        {
            Projectiles.SetPreviewing(false);
            OnSeismicChargeFire.Invoke();
        }
    }

    public void GetCarveInput(InputAction.CallbackContext context)
    {
        if (context.performed && !IsCarving)
        {
            IsCarving = true;
            ControllerYoshi02.SetCarveInput(IsCarving);
            EngineFX.SetCarving(IsCarving);
        }
        else if (context.performed && IsCarving)
        {
            IsCarving = false;
            ControllerYoshi02.SetCarveInput(IsCarving);
            EngineFX.SetCarving(IsCarving);
        }
    }
}
