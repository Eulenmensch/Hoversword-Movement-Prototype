using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum DamageTypes { Default, Laser, Dash }

public interface IDealDamage
{
    (int, DamageTypes) DealDamage();
}
