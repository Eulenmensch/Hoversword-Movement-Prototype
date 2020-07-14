using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DamageDealer : MonoBehaviour, IDealDamage
{
    [SerializeField] private int _damage;
    [SerializeField] private DamageTypes _damageType;

    public (int, DamageTypes) DealDamage()
    {
        return (_damage, _damageType);
    }
}
