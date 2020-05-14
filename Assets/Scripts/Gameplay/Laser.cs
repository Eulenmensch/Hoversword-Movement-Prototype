using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Laser : Obstacle
{
    [Header("Laser")]
    [SerializeField]
    private GameObject _laserModel;

    public override void SetActive(bool value)
    {
        base.SetActive(value);

        _laserModel.SetActive(value);
    }
}