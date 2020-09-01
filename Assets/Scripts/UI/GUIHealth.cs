using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GUIHealth : MonoBehaviour
{
    [SerializeField] PlayerHandling Handling;
    [SerializeField]
    private GameObject _healthGraphic;
    //[SerializeField]
    private PlayerHealth _playerHealth;

    private List<GameObject> _healthGraphicList = new List<GameObject>();

    [SerializeField] GameObject[] BlueCells;
    [SerializeField] GameObject[] YellowCells;
    [SerializeField] GameObject[] RedCells;

    [SerializeField] Animator SparkAnimator;
    [SerializeField] Image SparkImage;
    [SerializeField] Material[] SparkMaterials;

    [SerializeField] Image SpeedGaugeImage;
    [SerializeField, ColorUsage(true, true)] Color DefaultColor;
    [SerializeField, ColorUsage(true, true)] Color DashColor;

    private int _health;

    private void Awake()
    {
        _playerHealth = FindObjectOfType<PlayerHealth>();

        if (_playerHealth == null)
        {
            Debug.LogError("GUI has no reference to player health!");
            return;
        }

        for (int i = 0; i < _playerHealth.maxHealth; i++)
        {
            // _healthGraphicList.Add(AddBar());
        }
        UpdateHealthBar();
        UpdateSparks();
    }

    private void Update()
    {
        if (_playerHealth == null)
            return;

        if (_playerHealth.health != _health)
        {
            UpdateHealthBar();
            UpdateSparks();
        }
        UpdateSpeedGauge();
    }

    private void UpdateHealthBar()
    {
        _health = _playerHealth.health;

        int i = 0;

        foreach (var cell in BlueCells)
        {
            cell.SetActive(false);
        }
        foreach (var cell in YellowCells)
        {
            cell.SetActive(false);
        }
        foreach (var cell in RedCells)
        {
            cell.SetActive(false);
        }

        if (_health > 3)
        {
            foreach (var cell in BlueCells)
            {
                cell.SetActive(i < _health);
                i++;
            }
        }
        else if (_health > 1)
        {
            foreach (var cell in YellowCells)
            {
                cell.SetActive(i < _health);
                i++;
            }
        }
        else if (_health == 1)
        {
            foreach (var cell in RedCells)
            {
                cell.SetActive(i < _health);
                i++;
            }
        }
    }

    private void UpdateSparks()
    {
        _health = _playerHealth.health;

        SparkAnimator.SetInteger("Health", _health);

        if (_health > 3)
        {
            SparkImage.material = SparkMaterials[0];
        }
        else if (_health > 1)
        {
            SparkImage.material = SparkMaterials[1];
        }
        else if (_health == 1)
        {
            SparkImage.material = SparkMaterials[2];
        }
    }

    private void UpdateSpeedGauge()
    {
        float fill = SpeedGaugeImage.fillAmount;
        PhysicsUtilities.ScaleValueWithSpeed(ref fill, 0, 1, Handling.RB, Handling.MaxSpeed);
        SpeedGaugeImage.fillAmount = fill;
        SpeedGaugeImage.material.SetFloat("_GlowIntensity", fill);
        if (Handling.IsDashing)
        {
            SpeedGaugeImage.material.SetColor("_HDRColor", DashColor);
        }
        else
        {
            SpeedGaugeImage.material.SetColor("_HDRColor", DefaultColor);
        }
    }

    private GameObject AddBar()
    {
        return Instantiate(_healthGraphic, transform);
    }
}
