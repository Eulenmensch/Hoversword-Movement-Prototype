using UnityEngine;
using DG.Tweening;
using UnityEngine.InputSystem;
using UnityEngine.Animations.Rigging;

public class CharacterRigController : MonoBehaviour
{
    [SerializeField] private float MoveDuration;
    [SerializeField] float RotateAmount;
    [SerializeField] float MoveAmount;
    [SerializeField] float HipDampingAmount;
    [SerializeField] float HipDampingScale;
    [SerializeField] float HipHeight;
    [SerializeField] float MaxHipDistance;
    [SerializeField] LayerMask GroundMask;

    [SerializeField] PlayerHandling Handling;
    [SerializeField] TwoBoneIKConstraint[] LegIKs;
    [SerializeField] ChainIKConstraint[] HandIKs;

    private Vector3 MoveBy;
    private Vector3 RotateBy;

    private void OnEnable()
    {
        PlayerEvents.Instance.OnJump += ToggleLegIKOff;
        PlayerEvents.Instance.OnJumpCancel += ToggleLegIKOn;
        PlayerEvents.Instance.OnLand += ToggleLegIKOn;
        PlayerEvents.Instance.OnStartAim += ToggleLegIKOff;
        PlayerEvents.Instance.OnStartAim += ToggleHandIKOn;
        PlayerEvents.Instance.OnStopAim += ToggleLegIKOn;
        PlayerEvents.Instance.OnStopAim += ToggleHandIKOff;
    }

    private void Start()
    {
        ToggleLegIKOn();
        ToggleHandIKOff();
    }

    void Update()
    {
        if ( !Handling.IsActive )
        {
            return;
        }

        MoveRoot();
        RotateSpine();
        HipDamping();
    }

    private void MoveRoot()
    {
        this.transform.DOLocalMove( MoveBy * MoveAmount, MoveDuration, false );
    }

    private void RotateSpine()
    {
        this.transform.DOLocalRotate( RotateBy * RotateAmount, MoveDuration, RotateMode.Fast );
    }

    private void HipDamping()
    {
        if ( Handling.IsGrounded )
        {
            RaycastHit hit;
            Physics.Raycast( this.transform.position, Vector3.down, out hit, 5.0f, GroundMask );
            float yPos = ( hit.distance - HipHeight ) * HipDampingScale;
            yPos = Mathf.Clamp( yPos, -1, MaxHipDistance ); //the -1 minimum value is basically no minimum, as the value never goes below -0.2 anyways
            this.transform.DOLocalMoveY( yPos, HipDampingAmount, false );
        }
    }

    private void ToggleLegIKOn()
    {
        foreach ( var legIK in LegIKs )
        {
            legIK.weight = 1;
        }
    }
    private void ToggleLegIKOff()
    {
        foreach ( var legIK in LegIKs )
        {
            legIK.weight = 0;
        }
    }

    private void ToggleHandIKOn()
    {
        foreach ( var handIK in HandIKs )
        {
            handIK.weight = 1;
        }
    }
    private void ToggleHandIKOff()
    {
        foreach ( var handIK in HandIKs )
        {
            handIK.weight = 0;
        }
    }

    public void SetMoveInput(InputAction.CallbackContext context)
    {
        Vector2 move = context.ReadValue<Vector2>();
        MoveBy = new Vector3( move.x, -0.2f, 0 );

        RotateBy = new Vector3( 0, move.x, 0 );
    }

}
