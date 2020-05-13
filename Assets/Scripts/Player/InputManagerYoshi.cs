using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.Events;

[RequireComponent( typeof( HoverBoardControllerYoshi02 ) )]
public class InputManagerYoshi : MonoBehaviour
{
    [SerializeField] UnityEvent OnJump;
    private HoverBoardControllerYoshi02 ControllerYoshi02;

    private bool IsCrouching;
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
        if ( context.performed && !IsCrouching )
        {
            OnJump.Invoke();
        }
    }
}
