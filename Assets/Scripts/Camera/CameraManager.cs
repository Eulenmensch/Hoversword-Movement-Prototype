using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Cinemachine;

public class CameraManager : MonoBehaviour
{
    private InputActionsAsset inputActions; //default controls is just the Csharp code you generate from the action maps asset
    private Vector2 LookDelta;

    private void Awake() => inputActions = new InputActionsAsset();

    private void OnEnable() => inputActions.Player.Enable();
    private void OnDisable() => inputActions.Player.Disable();

    [SerializeField] private string _xAxisName = "Mouse X";
    [SerializeField] private string _yAxisName = "Mouse Y";

    [SerializeField, Range(0,1)] private float _xAxisDead = 0.05f;
    [SerializeField, Range(0, 1)] private float _yAxisDead = 0.05f;



    private void Update()
    {
        CinemachineCore.GetInputAxis = GetAxisCustom;
    }

    public float GetAxisCustom(string axisName)
    {
        LookDelta = inputActions.Player.Look.ReadValue<Vector2>(); // reads the available camera values and uses them.
        //LookDelta.Normalize();

        if (axisName == _xAxisName)
        {
            float ret = LookDelta.x;
            if ((ret > 0 && ret < _xAxisDead) || (ret < 0 && ret > -_xAxisDead))
                ret = 0;

            return ret;
        }
        else if (axisName == _yAxisName)
        {
            float ret = LookDelta.y;
            if ((ret > 0 && ret < _yAxisDead) || (ret < 0 && ret > -_yAxisDead))
                ret = 0;

            return ret;
        }
        return 0;
    }
}