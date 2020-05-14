using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class Projectile : MonoBehaviour
{
    [SerializeField] private float _lifespan = 10f;
    private float _startTimestamp;

    private void Start()
    {
        _startTimestamp = Time.time;
    }

    protected virtual void Update()
    {
        if (_startTimestamp + _lifespan < Time.time)
        {
            Destroy(this.gameObject);
        }
    }
}
