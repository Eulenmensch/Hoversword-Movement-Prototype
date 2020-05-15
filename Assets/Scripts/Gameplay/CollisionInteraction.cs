using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;


public enum DamageType { Laser }
public enum DamageDirectionType { Velocity }

public struct CollisionInteraction
{
    // Damage
    public bool applyDamage;
    public int damage;
    public DamageType damageType;

    public float forceMagnitude;
    public DamageDirectionType damageDirectionType;

    // Health
    //public bool applyHealth;
    //public int health;

    //public InteractionData(int damage, DamageType damageType, float forceMagnitude, DamageDirectionType damageDirectionType)
    //{
    //    this.damage = damage;
    //    this.damageType = damageType;
    //    this.forceMagnitude = forceMagnitude;
    //    this.damageDirectionType = damageDirectionType;
    //    //this.forceDirection = forceDirection;
    //}

    public CollisionInteraction(bool applyDamage/*, bool applyHealth*/) : this()
    {
        this.applyDamage = applyDamage;
        //this.applyHealth = applyHealth;
    }

    public void SetDamage(int damage, DamageType damageType, float forceMagnitude, DamageDirectionType damageDirectionType)
    {
        this.damage = damage;
        this.damageType = damageType;
        this.forceMagnitude = forceMagnitude;
        this.damageDirectionType = damageDirectionType;
    }

    //internal void SetHealth(int health)
    //{
    //    this.health = health;
    //}
}
