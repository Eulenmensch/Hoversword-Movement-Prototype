using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IGiveHealth
{
    HealthGainData GiveHealth(bool isAttack);
}

public enum HealingTypes { Adding, Reset, Full }

public struct HealthGainData
{
    public HealingTypes healingType;
    public int healthGain;

    public HealthGainData(HealingTypes healingType, int healthGain)
    {
        this.healingType = healingType;
        this.healthGain = healthGain;
    }
}