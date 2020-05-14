using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LaserShot : Projectile
{
    [SerializeField] private float _speed;

    void FixedUpdate()
    {
        transform.position += transform.forward * _speed * Time.deltaTime;
    }
}
