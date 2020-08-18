using UnityEngine;
using Unity.Mathematics;
using System;

public class BoardShake : MonoBehaviour
{
    [SerializeField] Transform[] ShakeBones;
    [SerializeField] float ShakeIntensity;
    [SerializeField] float ScrollSpeed;
    [SerializeField, Range( 0, 360 )] float MaxAngle;

    private Vector3[] DefaultPositions;
    private Quaternion[] DefaultRotations;
    private float Scroll;

    private void Start()
    {
        DefaultPositions = new Vector3[ShakeBones.Length];
        DefaultRotations = new Quaternion[ShakeBones.Length];
        for ( int i = 0; i < ShakeBones.Length; i++ )
        {
            DefaultPositions[i] = ShakeBones[i].localPosition;
            DefaultRotations[i] = ShakeBones[i].localRotation;
        }
    }

    private void Update()
    {
        Scroll += Time.deltaTime * ScrollSpeed;
        for ( int i = 0; i < ShakeBones.Length; i++ )
        {
            Transform bone = ShakeBones[i];

            float perlinNoise = noise.cnoise( new float2( Scroll, Scroll ) );

            Vector3 shakeDirection = new Vector3();
            shakeDirection.x = UnityEngine.Random.Range( -1, 1 );
            shakeDirection.y = UnityEngine.Random.Range( -1, 1 );
            shakeDirection.z = UnityEngine.Random.Range( -1, 1 );
            shakeDirection = shakeDirection.normalized;

            bone.localPosition = DefaultPositions[i];
            bone.localPosition += perlinNoise * shakeDirection * ShakeIntensity;

            Vector3 shakeAngle = new Vector3();
            shakeAngle.x = UnityEngine.Random.Range( -MaxAngle, MaxAngle );
            shakeAngle.y = UnityEngine.Random.Range( -MaxAngle, MaxAngle );
            shakeAngle.z = UnityEngine.Random.Range( -MaxAngle, MaxAngle );

            Vector3 rotation = DefaultRotations[i].eulerAngles;
            rotation += shakeAngle * perlinNoise;
            bone.localRotation = Quaternion.Euler( rotation );
        }
    }
}