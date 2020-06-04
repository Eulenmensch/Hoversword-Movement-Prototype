using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AimRotation : MonoBehaviour
{
    private CombatController _combatController;

    private Vector3 _startRotation;

    [SerializeField] private bool _rotateY;
    [SerializeField] private float _lerpSpeedAiming = 20f;
    [SerializeField] private float _lerpSpeed = 20f;


    void Awake()
    {
        _combatController = GetComponentInParent<CombatController>();
        _startRotation = transform.eulerAngles;
    }

    private void Update()
    {
        AimCharacter();
    }

    private void AimCharacter()
    {
        if (_combatController.isAiming)
        {
            Vector3 camDirection = new Vector3(Camera.main.transform.forward.x,
                _rotateY ? Camera.main.transform.forward.y : 0, Camera.main.transform.forward.z);
            Quaternion rotation = Quaternion.LookRotation(camDirection);
            rotation *= Quaternion.Euler(_startRotation);
            transform.rotation = Quaternion.Slerp(transform.rotation, rotation, _lerpSpeedAiming * Time.deltaTime);
        }
        else
        {
            Quaternion rotation = transform.parent.rotation;
            rotation *= Quaternion.Euler(_startRotation);
            transform.rotation = Quaternion.Slerp(transform.rotation, rotation, _lerpSpeed * Time.deltaTime);
        }
    }
}
