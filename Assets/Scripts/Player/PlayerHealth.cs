using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerHealth : MonoBehaviour
{
    [SerializeField] private int _initialHealth;

    [SerializeField] private int _maxHealth;
    public int maxHealth => _maxHealth;

    [SerializeField] private int _health;
    public int health
    {
        get { return _health; }
        private set { _health = Mathf.Clamp(value, 0, maxHealth); }
    }

    [SerializeField] private float _damageCooldown = 1f;
    private float _damageTimestamp;

    private PlayerEffects _playerEffects;
    [SerializeField] private AudioSource _damageSound;


    private void Awake()
    {
        ResetHealth();
        _playerEffects = transform.GetComponentInChildren<PlayerEffects>();
    }

    private void ResetHealth()
    {
        health = _initialHealth;
    }

    public void AddHealth(int value)
    {
        health += Mathf.Min(value, _maxHealth);
    }

    public void Damage(int value, DamageTypes damageType)
    {
        if (!(Time.unscaledTime > _damageTimestamp + _damageCooldown))
            return;

        health -= value;

        _damageTimestamp = Time.unscaledTime;
        _playerEffects.Damage(damageType);
        if (_damageSound != null)
            _damageSound.Play();
    }
}
