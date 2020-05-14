using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public enum DamageType { Laser }
public enum DamageDirectionType { Velocity }

public struct DamageData
{
    public int damage;
    public DamageType damageType;

    public float forceMagnitude;
    public DamageDirectionType damageDirectionType;
    //public Vector3 forceDirection;

    public DamageData(int damage, DamageType damageType, float forceMagnitude, DamageDirectionType damageDirectionType)
    {
        this.damage = damage;
        this.damageType = damageType;
        this.forceMagnitude = forceMagnitude;
        this.damageDirectionType = damageDirectionType;
        //this.forceDirection = forceDirection;
    }
}
