using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Checkpoint : MonoBehaviour
{
    [SerializeField] private Transform _targetPosition;
    public Transform targetPosition => _targetPosition;

    [SerializeField] private float _speed = 1f;
    public float speed => _speed;

}
