using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Battery : Machine, IAttackable
{
    [Header("Battery")]
    [SerializeField] private GameObject _batteryModel;
    [SerializeField] private GameObject _batteryBrokenModel;

    [SerializeField] private List<GameObject> _parts = new List<GameObject>();
    private List<IShutOff> _partsToShutOff = new List<IShutOff>();

    //[Header( "Attack Interaction" )]
    //[SerializeField] private int _healthGain;

    [Header("Effects")]
    [SerializeField] private AudioSource _destroySound;

    private Wreckage[] _wreckages;


    private void Awake()
    {
        foreach (var item in _parts)
        {
            if (item == null) continue;

            IShutOff[] shutOffs = item.GetComponents<IShutOff>();

            if (shutOffs != null)
            {
                foreach (var shutOff in shutOffs)
                {
                    _partsToShutOff.Add(shutOff);
                    shutOff.Register(this);
                }
            }
        }

        _wreckages = GetComponentsInChildren<Wreckage>(true);
    }

    public override void TriggerEnter(GameObject caller)
    {
        Destroy();
    }

    private void Destroy()
    {
        if (!_isActive)
            return;

        SetActive(false);

        _batteryModel.SetActive(false);
        _batteryBrokenModel.SetActive(true);

        foreach (var item in _partsToShutOff)
        {
            item.ShutOff(this);
        }

        foreach (var item in _wreckages)
        {
            item.Push();
        }

        _destroySound?.Play();
    }

    public void GetAttacked(int attackID, AttackTypes _attackType)
    {
        Destroy();
        //AttackInteraction attackInteraction = new AttackInteraction(_healthGain);
        //attackInteraction.SetHealth(_healthGain);
        //return attackInteraction;
    }
}
