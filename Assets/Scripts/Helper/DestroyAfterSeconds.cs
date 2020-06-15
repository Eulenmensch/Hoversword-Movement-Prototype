using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DestroyAfterSeconds : MonoBehaviour
{
    [SerializeField] private float _duration;
    private float _timestamp;

    void Start()
    {
        _timestamp = Time.time;
    }

    // Update is called once per frame
    void Update()
    {
        if (Time.time > _timestamp + _duration)
        {
            Destroy(gameObject);
        }
    }
}
