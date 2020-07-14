using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DestroyOnCollision : MonoBehaviour, ICollidable
{
    public void TriggerEnter(GameObject caller)
    {
        Destroy(gameObject);
    }

    public void TriggerExit() { }
}
