using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DestroyOnCollision : MonoBehaviour, ICollidable
{
    public void Collide()
    {
        Destroy(gameObject);
    }
}
