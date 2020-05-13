using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GUIHealth : MonoBehaviour
{
    [SerializeField]
    private GameObject _healthGraphic;
    [SerializeField]
    private PlayerHealth _playerHealth;

    private List<GameObject> _healthGraphicList = new List<GameObject>();

    private int _health;

    private void Awake()
    {
        for (int i = 0; i < _playerHealth.maxHealth; i++)
        {
            _healthGraphicList.Add(AddBar());
        }
        UpdateHealthBar();
    }

    private void Update()
    {
        if (_playerHealth.health != _health)
        {
            UpdateHealthBar();
        }
    }

    private void UpdateHealthBar()
    {
        _health = _playerHealth.health;

        int i = 0;

        foreach (var item in _healthGraphicList)
        {
            item.SetActive(i < _health);
            i++;
        }
    }

    private GameObject AddBar()
    {
        return Instantiate(_healthGraphic, transform);
    }
}
