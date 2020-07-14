using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : MonoBehaviour
{
    // Used this for other entities trying to 'attack' the player
    [SerializeField] private Transform _playerAttackPosition;
    public Transform playerAttackPosition { get { return _playerAttackPosition; } private set { _playerAttackPosition = value; } }

    private void Awake()
    {
        if (_playerAttackPosition == null)
        {
            playerAttackPosition = transform;
        }
    }
}
