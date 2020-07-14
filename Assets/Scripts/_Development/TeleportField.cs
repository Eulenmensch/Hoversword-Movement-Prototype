using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TeleportField : MonoBehaviour, ICollidable
{
    public Transform target;

    public void TriggerEnter(GameObject caller)
    {
        //CollisionInteraction collisionInteraction = new CollisionInteraction(false);
        //collisionInteraction.SetTeleport(true, target.position);
        //return collisionInteraction;
    }

    public void TriggerExit() { }
}
