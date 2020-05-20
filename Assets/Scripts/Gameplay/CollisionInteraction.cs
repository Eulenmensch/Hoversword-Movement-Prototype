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

    public bool teleport;
    public Vector3 teleportTarget;

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

    public CollisionInteraction(bool interaction/*, bool applyHealth*/) : this()
    {
        //this.applyDamage = applyDamage;
        //this.applyHealth = applyHealth;
    }

    public void SetDamage(bool applyDamage, int damage, DamageType damageType, float forceMagnitude, DamageDirectionType damageDirectionType)
    {
        this.applyDamage = applyDamage;
        this.damage = damage;
        this.damageType = damageType;
        this.forceMagnitude = forceMagnitude;
        this.damageDirectionType = damageDirectionType;
    }

    public void SetTeleport(bool teleport, Vector3 teleportTarget)
    {
        this.teleport = teleport;
        this.teleportTarget = teleportTarget;
    }

    //internal void SetHealth(int health)
    //{
    //    this.health = health;
    //}
}
