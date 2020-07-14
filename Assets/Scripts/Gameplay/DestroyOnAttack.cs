using System.Collections;
using System.Collections.Generic;
using System.Security.Cryptography;
using UnityEngine;

public class DestroyOnAttack : MonoBehaviour, IAttackable
{
    public void GetAttacked(int attackID, AttackTypes _attackType)
    {
        Destroy(gameObject);
    }
}
