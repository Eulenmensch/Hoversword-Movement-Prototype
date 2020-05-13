using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public enum DamageType { Laser }

public struct DamageData
{
    public int damage;
    public DamageType damageType;

    public float forceMagnitude;
    public bool isDirected;
    public Vector3 forceDirection;

    public DamageData(int damage, DamageType damageType, float forceMagnitude, bool isDirected, Vector3 forceDirection)
    {
        this.damage = damage;
        this.damageType = damageType;
        this.forceMagnitude = forceMagnitude;
        this.isDirected = isDirected;
        this.forceDirection = forceDirection;
    }
}
