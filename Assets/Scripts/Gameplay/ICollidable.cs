using System.Collections;
using System.Collections.Generic;
using System.Runtime.Remoting;
using UnityEngine;

public interface ICollidable
{
    // CollisionInteraction Collide();
    void TriggerEnter(GameObject caller);
    void TriggerExit();
}
