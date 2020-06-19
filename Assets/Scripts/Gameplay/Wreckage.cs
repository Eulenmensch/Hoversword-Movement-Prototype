using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Wreckage : MonoBehaviour
{
    private Rigidbody _rb;

    private void Awake()
    {
        _rb = GetComponent<Rigidbody>();
    }

    public void Push()
    {
        _rb.AddForce(Camera.main.transform.forward * Random.Range(50f, 75f), ForceMode.Impulse);
    }
}
