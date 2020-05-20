using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SetActiveOnStart : MonoBehaviour
{
    public bool active = false;
    void Start()
    {
        gameObject.SetActive(active);
    }
}
