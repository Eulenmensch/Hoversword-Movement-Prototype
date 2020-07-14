using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Laser : Machine
{
    [Header("Laser")]
    [SerializeField] private GameObject[] _laserModel;

    public override void SetActive(bool value)
    {
        base.SetActive(value);

        foreach (var item in _laserModel)
        {
            if (item != null)
                item.SetActive(value);
        }
    }
}