using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

public class PostProcessingController : MonoBehaviour
{
    [SerializeField] private Transform Player;
    [SerializeField] private PostProcessVolume PostProcessVolume;
    [SerializeField] private PlayerHandling Handling;

    [SerializeField, Range( 0, 1 )] private float MaxChromaticAberration;


    private void Update()
    {
        var pos = Camera.main.WorldToViewportPoint( Player.position );
        CustomMotionBlurPPSSettings motionBlur;
        PostProcessVolume.profile.TryGetSettings( out motionBlur );
        Vector4Parameter para = new Vector4Parameter();
        para.value = pos;
        motionBlur._Offset.value.x = pos.x;
        motionBlur._Offset.value.y = pos.y;

        ChromaticAberration chromaticAberration;
        PostProcessVolume.profile.TryGetSettings( out chromaticAberration );
        if ( chromaticAberration != null )
        {
            float value = 0;
            PhysicsUtilities.ScaleValueWithSpeed( ref value, 0, MaxChromaticAberration, Handling.RB, Handling.MaxSpeed );
            chromaticAberration.intensity.value = value;
        }
    }
}