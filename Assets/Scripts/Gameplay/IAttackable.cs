using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum AttackTypes
{
    Flip,
    Slash
}

public interface IAttackable
{
    void GetAttacked(int attackID, AttackTypes _attackType);

    //void ExitAttacked();
}
