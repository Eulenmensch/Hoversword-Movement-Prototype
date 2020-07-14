using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HealthGiver : MonoBehaviour, IGiveHealth
{
    [SerializeField] private int _healthForCollision;
    [SerializeField] private int _healthForAttack;

    public int GiveHealth(bool isAttack)
    {
        return isAttack ? _healthForAttack : _healthForCollision;
    }

    private void OnValidate()
    {
        _healthForCollision = Mathf.Max(0, _healthForCollision);
        _healthForAttack = Mathf.Max(0, _healthForAttack);
    }
}
