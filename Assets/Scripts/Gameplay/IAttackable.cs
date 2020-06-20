using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IAttackable
{
    AttackInteraction GetAttacked(int attackID);

    void ExitAttacked();
}
