using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum DamageTypes { Default, Laser }

public interface IDealDamage
{
    (int, DamageTypes) DealDamage();
}
