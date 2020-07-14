using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Pusher : MonoBehaviour, IPush
{
    [SerializeField] float _pushStrength;
    [SerializeField] PushTypes _pushType;

    public (float, PushTypes) Push()
    {
        return (_pushStrength, _pushType);
    }
}
