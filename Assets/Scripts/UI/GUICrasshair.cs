using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GUICrasshair : MonoBehaviour
{
    private CombatController _combatController;
    private Image _image;

    private void Awake()
    {
        _combatController = FindObjectOfType<CombatController>();
        _image = GetComponent<Image>();
    }

    void Update()
    {
        if (!_image.enabled)
        {
            if (_combatController.isAiming)
            {
                _image.enabled = true;
            }
        }
        else if (!_combatController.isAiming)
        {
            _image.enabled = false;
        }
    }
}
