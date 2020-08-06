using UnityEngine;
using Cinemachine;
using UnityEngine.InputSystem;
using System.Collections;
using DG.Tweening;

public class HoverCameraController : MonoBehaviour
{
    [SerializeField] private CinemachineFreeLook FreeLook;
    [SerializeField] private PlayerHandling Handling;
    [SerializeField] private PlayerDash Dash;
    [SerializeField] private Rigidbody RB;
    [SerializeField] float MaxZOffset;
    [SerializeField] float MaxXOffset;
    // [SerializeField] float ZLerpTime;
    [SerializeField] float XLerpTime;
    [SerializeField] float ZLerpTime;
    [SerializeField] float CarveZOffset;
    [SerializeField] float CarveXMultiplier;
    [SerializeField] AnimationCurve FOVCurve;

    private float ZOffset;
    private float XOffset;
    private Vector3 TrackedObjectOffset;
    private float PulseFrame;
    private float DefaultFOV;
    private bool IsDashing;

    private void Start()
    {
        DefaultFOV = FreeLook.m_Lens.FieldOfView;
    }

    private void FixedUpdate()
    {
        ScaleZOffsetWithSpeed();
        SetGroundOffset();
        SetAirOffset();
        SetCarveOffset();
    }

    private void Update()
    {
        PulseFOV();
    }

    private void ScaleZOffsetWithSpeed()
    {
        PhysicsUtilities.ScaleForceWithSpeed(ref ZOffset, 0, MaxZOffset, RB, Handling.MaxSpeed);
    }

    public void ScaleXOffsetWithTurnInput(InputAction.CallbackContext context)
    {
        Vector2 inputVector = context.ReadValue<Vector2>();
        XOffset = inputVector.x * MaxXOffset;
    }

    private void SetOffset(float _xOffset, float _zOffset)
    {
        TrackedObjectOffset.x = Mathf.Lerp(TrackedObjectOffset.x, _xOffset, XLerpTime);
        TrackedObjectOffset.y = 1;
        TrackedObjectOffset.z = Mathf.Lerp(TrackedObjectOffset.z, _zOffset, ZLerpTime);

        for (int i = 0; i < 3; i++)
        {
            var rig = FreeLook.GetRig(i);
            var composer = rig.GetCinemachineComponent<CinemachineComposer>();
            composer.m_TrackedObjectOffset = TrackedObjectOffset;
        }
    }

    private void SetGroundOffset()
    {
        if (Handling.IsGrounded && !Handling.IsCarving)
        {
            SetOffset(XOffset, ZOffset);
        }
    }

    private void SetAirOffset()
    {
        if (!Handling.IsGrounded)
        {
            SetOffset(XOffset / MaxXOffset, 0);
        }
    }

    private void SetCarveOffset()
    {
        if (Handling.IsGrounded && Handling.IsCarving)
        {
            SetOffset(XOffset * CarveXMultiplier, CarveZOffset);
        }
    }

    private void PulseFOV()
    {
        if (Dash.DashTime == Dash.Duration)
        {
            if (Handling.IsDashing && PulseFrame <= Dash.DashTime)
            {
                this.IsDashing = true;
                PulseFrame += Time.deltaTime;
                var scaledPulseFrame = PulseFrame / Dash.DashTime;
                var fov = (FOVCurve.Evaluate(scaledPulseFrame) + 1) * DefaultFOV;
                FreeLook.m_Lens.FieldOfView = fov;
            }
        }
        else if (!Handling.IsDashing && this.IsDashing)
        {
            PulseFrame = 0;
            FreeLook.m_Lens.FieldOfView = DefaultFOV;
            this.IsDashing = false;
        }
    }

#if UNITY_EDITOR
    private void OnDrawGizmos()
    {
        Gizmos.DrawSphere(RB.transform.TransformPoint(TrackedObjectOffset), 0.2f);
    }
#endif
}