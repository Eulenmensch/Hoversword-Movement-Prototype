using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Shooter : MonoBehaviour, IShutOff
{
    private Transform _target;
    //private bool _isActive = true;
    //[SerializeField] private bool _targetPlayer;

    [Header("Scene References")]
    [SerializeField] private Transform _barrel;

    [Header("Detection")]
    [SerializeField] private float _detectionRange = 10f;
    [SerializeField] private float _aimSpeed = 1f;
    [SerializeField] private float _minAngleToShoot = 1f;
    private float _angle;

    [Header("Shooting")]
    [SerializeField] private Projectile _projectile;
    [SerializeField] private Transform _projectileSpawn;
    [SerializeField] private float _coolDownDuration = 1f;
    private float _shotTimestamp;


    private void Start()
    {
        _target = FindObjectOfType<Player>().transform;
        if (_target == null)
        {
            Debug.Log("Shooter coudn't find player");
        }
    }

    private void Update()
    {
        if (_target == null)
            return;

        if (Vector3.Distance(transform.position, _target.position) > _detectionRange)
            return;

        Aim();

        if (_angle < _minAngleToShoot)
        {
            if (_shotTimestamp + _coolDownDuration < Time.time)
            {
                Shoot();
            }
        }
    }

    private void Shoot()
    {
        _shotTimestamp = Time.time;
        Quaternion lookRotation = Quaternion.LookRotation(_target.position - _barrel.position);
        Instantiate(_projectile, _projectileSpawn.position, lookRotation);
    }

    private void Aim()
    {
        Quaternion lookRotation = Quaternion.LookRotation(_target.position - _barrel.position);
        _barrel.rotation = Quaternion.Slerp(_barrel.rotation, lookRotation, _aimSpeed * Time.deltaTime);
        _angle = Quaternion.Angle(_barrel.rotation, lookRotation);
    }

    public void ShutOff()
    {
        this.enabled = false;
        //_isActive = false;
    }
}
