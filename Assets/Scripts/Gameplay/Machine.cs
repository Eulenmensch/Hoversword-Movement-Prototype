﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Machine : Obstacle, IAttackable
{
    [Header("Machine")]
    [SerializeField] private GameObject _machineModel;
    [SerializeField] private GameObject _machineBrokenModel;

    [SerializeField] private List<GameObject> _parts = new List<GameObject>();
    private List<IShutOff> _partsToShutOff = new List<IShutOff>();

    [Header("Attack Interaction")]
    [SerializeField] private int _healthGain;

    [Header("Effects")]
    [SerializeField] private AudioSource _destroySound;



    protected override void Awake()
    {
        base.Awake();

        foreach (var item in _parts)
        {
            IShutOff[] shutOffs = item.GetComponents<IShutOff>();

            if (shutOffs != null)
            {
                foreach (var shutOff in shutOffs)
                {
                    _partsToShutOff.Add(shutOff);
                }
            }
            else
            {
                Debug.Log("shutoffs is null");
            }
        }
    }

    public override CollisionInteraction Collide()
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

    public AttackInteraction GetAttacked()
    {
        Destroy();
        AttackInteraction attackInteraction = new AttackInteraction(_healthGain);
        //attackInteraction.SetHealth(_healthGain);
        return attackInteraction;
    }
}