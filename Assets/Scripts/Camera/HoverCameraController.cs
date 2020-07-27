using UnityEngine;
using UnityEditor;
using Cinemachine;
using UnityEngine.InputSystem;

public class HoverCameraController : MonoBehaviour
{
    [SerializeField] private CinemachineFreeLook FreeLook;
    [SerializeField] private PlayerHandling Handling;
    [SerializeField] private Rigidbody RB;
    [SerializeField] float MaxZOffset;
    [SerializeField] float MaxXOffset;
    // [SerializeField] float ZLerpTime;
    [SerializeField] float XLerpTime;
    [SerializeField] AnimationCurve FOVCurve;

    private float ZOffset;
    private float XOffset;
    private Vector3 TrackedObjectOffset;

    private void FixedUpdate()
    {
        if (Handling.IsGrounded)
        {
            ScaleZOffsetWithSpeed();
            SetOffset(XOffset, ZOffset);
        }
        SetAirOffset();
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
        TrackedObjectOffset.x = Mathf.Lerp(TrackedObjectOffset.x, XOffset, XLerpTime);
        TrackedObjectOffset.y = 1;
        TrackedObjectOffset.z = ZOffset;

        for (int i = 0; i < 3; i++)
        {
            var rig = FreeLook.GetRig(i);
            var composer = rig.GetCinemachineComponent<CinemachineComposer>();
            composer.m_TrackedObjectOffset = TrackedObjectOffset;
        }
    }

    private void SetAirOffset()
    {
        if (!Handling.IsGrounded)
        {
            for (int i = 0; i < 3; i++)
            {
                var rig = FreeLook.GetRig(i);
                var composer = rig.GetCinemachineComponent<CinemachineComposer>();
                composer.m_TrackedObjectOffset = Vector3.Lerp(composer.m_TrackedObjectOffset, Vector3.zero, XLerpTime);
            }
        }
    }

    private void PulseFOV()
    {

    }

#if UNITY_EDITOR
    private void OnDrawGizmos()
    {
        Gizmos.DrawSphere(RB.transform.TransformPoint(TrackedObjectOffset), 0.2f);
    }
#endif
}