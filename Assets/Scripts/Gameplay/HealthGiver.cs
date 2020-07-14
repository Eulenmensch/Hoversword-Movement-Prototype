using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HealthGiver : MonoBehaviour, IGiveHealth
{
    [SerializeField] private HealingTypes _healingType;

    [SerializeField] private int _healthForCollision;
    [SerializeField] private int _healthForAttack;

    

    public HealthGainData GiveHealth(bool isAttack)
    {
        return new HealthGainData(_healingType, isAttack ? _healthForAttack : _healthForCollision);
    }

    private void OnValidate()
    {
        _healthForCollision = Mathf.Max(0, _healthForCollision);
        _healthForAttack = Mathf.Max(0, _healthForAttack);
    }
}
