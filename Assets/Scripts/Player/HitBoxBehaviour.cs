using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class HitBoxBehaviour : MonoBehaviour
{
    public GameObject HitBox;

    void FixedUpdate()
    {
        if (HitBox.activeInHierarchy)
        {
            GetComponent<BoxCollider>().enabled = true;
            transform.position = HitBox.transform.position;
            transform.rotation = HitBox.transform.rotation;
        }
        else
        {
            GetComponent<BoxCollider>().enabled = false;
        }
    }
}
