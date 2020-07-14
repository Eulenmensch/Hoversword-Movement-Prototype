using Cinemachine;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraReset : MonoBehaviour, IReset
{
    [SerializeField] private CinemachineFreeLook _cam;

    private void Awake()
    {
        _cam = GetComponent<CinemachineFreeLook>();
    }

    public void Reset()
    {
        _cam.PreviousStateIsValid = false;
        _cam.m_XAxis.Value = 0;
        _cam.m_YAxis.Value = 0.7f;
    }
}
