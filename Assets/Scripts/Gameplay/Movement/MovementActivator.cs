using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MovementActivator : MonoBehaviour
{
    [SerializeField] private float _detectionRange = 50f;

    private bool _isActivated;

    private Transform _target;

    private IMovement[] _movements;

    private void Awake()
    {
        _movements = GetComponents<IMovement>();
    }

    private void Start()
    {
        _target = FindObjectOfType<Player>().transform;
        if (_target == null)
            Debug.LogError("Object coudn't find player", this);
    }

    private void Update()
    {
        if (_target == null)
            return;

        if (!_isActivated)
        {
            if (Vector3.Distance(transform.position, _target.position) < _detectionRange)
            //if (Input.GetKeyDown(KeyCode.F))
            {
                _isActivated = true;
                foreach (var mover in _movements)
                {
                    mover.Move();
                }
            }
        }
        else if (Vector3.Distance(transform.position, _target.position) > _detectionRange)
        //else if (Input.GetKeyDown(KeyCode.F))
        {
            // Move Back
            _isActivated = false;
            foreach (var mover in _movements)
            {
                mover.Move();
            }
        }
    }
}
