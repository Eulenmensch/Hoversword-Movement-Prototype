﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class Machine : Obstacle, IAttackable
{
    [Header("Machine")]
    [SerializeField] private GameObject _machineModel;
    [SerializeField] private GameObject _machineBrokenModel;

    [SerializeField] private List<GameObject> _parts = new List<GameObject>();
    private List<IShutOff> _partsToShutOff = new List<IShutOff>();

    [SerializeField]
    private AudioSource _destroySound;

    protected override void Awake()
    {
        base.Awake();

        foreach (var item in _parts)
        {
            IShutOff shutOff = item.GetComponent<IShutOff>();
            if (shutOff != null)
            {
                _partsToShutOff.Add(shutOff);
            }
        }
    }

    public override DamageData Collide()
    {
        Destroy();

        return base.Collide();
    }

    private void Destroy()
    {
        if (!_isActive)
            return;

        SetActive(false);

        _machineModel.SetActive(false);
        _machineBrokenModel.SetActive(true);

        foreach (var item in _partsToShutOff)
        {
            item.ShutOff();
        }

        _destroySound?.Play();
    }

    public void GetAttacked()
    {
        Destroy();
    }
}
