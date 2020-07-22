using UnityEngine;
using Cinemachine;
using DG.Tweening;

public class HoverCameraController : MonoBehaviour
{
    [SerializeField] private CinemachineFreeLook FreeLook;
    [SerializeField] private PlayerHandling Handling;
    [SerializeField] private Rigidbody RB;
    [SerializeField] float MaxZOffset;
    [SerializeField] float TweenDuration;

    private float ZOffset;
    private Vector3 TrackedObjectOffset;

    private void FixedUpdate()
    {
        ScaleZOffsetWithSpeed();
    }

    private void ScaleZOffsetWithSpeed()
    {
        PhysicsUtilities.ScaleForceWithSpeed( ref ZOffset, 0, MaxZOffset, RB, Handling.MaxSpeed );
        TrackedObjectOffset = new Vector3( 0, 1, ZOffset );

        for ( int i = 0; i < 3; i++ )
        {
            var rig = FreeLook.GetRig( i );
            var composer = rig.GetCinemachineComponent<CinemachineComposer>();
            composer.m_TrackedObjectOffset = TrackedObjectOffset;
        }
    }


}