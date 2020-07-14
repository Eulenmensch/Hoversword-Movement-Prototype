using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class PlayerCheckpointResetter : MonoBehaviour
{
    private Rigidbody _rb;
    private Vector3 _startPosition;
    private Quaternion _startRotation;
    private Checkpoint _lastCheckpoint;

    private void Start()
    {
        _rb = GetComponent<Rigidbody>();
        _startPosition = transform.position;
        _startRotation = transform.rotation;
    }

    public void SetCheckpoint(Checkpoint checkpoint)
    {
        _lastCheckpoint = checkpoint;
    }

    public void Reset()
    {
        if (_lastCheckpoint == null)
        {
            transform.position = _startPosition;
            transform.rotation = _startRotation;
            _rb.velocity = Vector3.zero;
        }
        else
        {
            transform.position = _lastCheckpoint.targetPosition.position;
            transform.rotation = _lastCheckpoint.targetPosition.rotation;
            _rb.velocity = _lastCheckpoint.targetPosition.forward * _lastCheckpoint.speed;
        }

        ResetAll();
    }

    private static void ResetAll()
    {
        var resets = FindObjectsOfType<MonoBehaviour>().OfType<IReset>();
        foreach (var reset in resets)
        {
            reset.Reset();
        }
    }
}
