using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerHealth : MonoBehaviour
{
    [SerializeField]
    private int _initialHealth;

    [SerializeField]
    private int _maxHealth;
    public int maxHealth => _maxHealth;

    [SerializeField]
    private int _health;
    public int health
    {
        get { return _health; }
        private set { _health = Mathf.Clamp(value, 0, maxHealth); }
    }

    [SerializeField]
    private AudioSource _damageSound;

    private void Awake()
    {
        ResetHealth();
    }

    private void ResetHealth()
    {
        health = _initialHealth;
    }

    public void AddHealth(int value)
    {
        health += Mathf.Max(0, value);

        // call visualization
    }

    public void Damage(int value)
    {
        health -= value;

        if (_damageSound != null)
        {
            _damageSound.Play();
        }
    }
}
