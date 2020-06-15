using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LaserShot : Projectile
{
    [SerializeField] private float _speed;

    private Transform _target;
    public Transform target { get { return _target; } set { _target = value; } }
    [SerializeField] private bool _steerToPlayer;
    [SerializeField] private float _maxSteerAnglePerSecond = 1f;

    protected override void Start()
    {
        base.Start();

        if (!_steerToPlayer)
            return;

        _target = FindObjectOfType<Player>().playerAttackPosition;
        if (_target == null)
        {
            Debug.Log("Projectile coudn't find player");
        }
    }

    void FixedUpdate()
    {
        if (_steerToPlayer && target != null)
        {
            float steer = _maxSteerAnglePerSecond * Mathf.Rad2Deg * Time.deltaTime;
            //print(steer);
            Vector3 direction = Vector3.RotateTowards(transform.forward, (_target.position - transform.position).normalized,
                steer, 1f);
            transform.rotation = Quaternion.LookRotation(direction, Vector3.up);
        }

        transform.position += transform.forward * _speed * Time.deltaTime;
    }
}
