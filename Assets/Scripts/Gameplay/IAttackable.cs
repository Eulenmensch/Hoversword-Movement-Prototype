using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum AttackType
{
    Flip,
    Slash
}

public interface IAttackable
{
    AttackInteraction GetAttacked(int attackID, AttackType _attackType);

    void ExitAttacked();
}
