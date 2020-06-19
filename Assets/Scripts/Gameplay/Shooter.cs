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

    public List<Machine> energySources { get; set; } = new List<Machine>();

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

    public virtual void ShutOff(Machine machine)
    {
        //SetActive(false);
        if (energySources.Contains(machine))
        {
            energySources.Remove(machine);
        }
        else
        {
            Debug.Log("Energy Source wasn't register!");
        }

        if (energySources.Count == 0)
        {
            this.enabled = false;
        }
    }

    public void Register(Machine machine)
    {
        if (!energySources.Contains(machine))
        {
            energySources.Add(machine);
        }
        else
        {
            Debug.Log("Energy Source tried to register twice!");
        }
    }
}
