using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RotateWithTarget : MonoBehaviour
{
    [SerializeField] private Transform _target;
    private Transform t;

    private void Awake()
    {
        t = transform;
    }

    void Update()
    {
        //t.eulerAngles = new Vector3(_target.eulerAngles.x, 0, _target.eulerAngles.z);

        Vector3 lookDirection = _target.forward;
        lookDirection.y = 0;

        Quaternion rot = Quaternion.LookRotation(lookDirection);
        t.rotation = rot;

        Debug.DrawLine(transform.position, transform.position + lookDirection.normalized * 5f, Color.red);
    }
}
