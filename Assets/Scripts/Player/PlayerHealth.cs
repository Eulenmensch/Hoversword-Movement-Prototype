using UnityEngine;

public class PlayerHealth : MonoBehaviour, IReset
{
    private PlayerHandling _playerHandling;
    private PlayerCheckpointResetter _playerCheckpointResetter;
    private RagdollController _ragdollController;

    [SerializeField] private bool _isImmortal;

    [SerializeField] private int _initialHealth;

    [SerializeField] private int _maxHealth;
    public int maxHealth => _maxHealth;

    [SerializeField] private int _resetHealth;

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
        _playerHandling = GetComponent<PlayerHandling>();
        _playerCheckpointResetter = GetComponent<PlayerCheckpointResetter>();
        _ragdollController = GetComponent<RagdollController>();
        _playerEffects = GetComponentInChildren<PlayerEffects>();

        _health = _initialHealth;
    }

    public void ResetHealth()
    {
        health = Mathf.Max(_resetHealth, _health);
    }

    public void FillHealth()
    {
        health = maxHealth;
    }

    public void AddHealth(int value)
    {
        health += Mathf.Min(value, _maxHealth);
        PlayerEvents.Instance.Heal();
    }

    public void Damage(int value, DamageTypes damageType)
    {
        if (!(Time.unscaledTime > _damageTimestamp + _damageCooldown))
            return;

        health = Mathf.Max(0, health - value);

        _damageTimestamp = Time.unscaledTime;
        _playerEffects.Damage(damageType);
        PlayerEvents.Instance.TakeDamage();
        if (damageType == DamageTypes.Laser)
            _damageSound.Play();

        if (health <= 0 && !_isImmortal)
            Die();
    }

    public void UseHealth(int value)
    {
        health -= value;
        if (health <= 0)
            Die();
    }

    public void HealthGain(HealthGainData healthGainData)
    {
        switch (healthGainData.healingType)
        {
            case HealingTypes.Adding:
                AddHealth(healthGainData.healthGain);
                break;
            case HealingTypes.Reset:
                ResetHealth();
                break;
            case HealingTypes.Full:
                FillHealth();
                break;
        }
    }

    private void Die()
    {
        _ragdollController.RagdollCrash();
        _playerHandling.IsActive = false;
        _playerCheckpointResetter.Reset();
        TimeManager.Instance.StartDeath();
        PlayerEvents.Instance.Death();
    }

    public void Reset()
    {
        ResetHealth();
        _playerHandling.IsActive = true;
        TimeManager.Instance.StopDeath();
        PlayerEvents.Instance.Reset();
    }
}
