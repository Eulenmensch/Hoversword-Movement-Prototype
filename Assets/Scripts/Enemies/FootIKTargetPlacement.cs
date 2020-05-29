using UnityEngine;
using DG.Tweening;

public class FootIKTargetPlacement : MonoBehaviour
{
    public float MaxFootHeight;
    public float TweenTime;
    public float MaxDist;
    public Transform FootPos;
    // Start is called before the first frame update
    void Start()
    {
        MaxDist *= 1.5f;
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        var distanceRatio = Mathf.Clamp( ( ( FootPos.position - transform.position ).magnitude / MaxDist ), 0, 1 );

        var height = Mathf.Lerp( 0, MaxFootHeight, distanceRatio );

        if ( ( FootPos.position - transform.position ).magnitude >= MaxDist )
        {
            transform.DOMove( FootPos.position, TweenTime ).SetEase( Ease.InOutQuad );
        }
        //transform.position = FootPos.position;
    }
}