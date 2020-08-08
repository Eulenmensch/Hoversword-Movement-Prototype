using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SandTrail : MonoBehaviour
{
    [SerializeField] Transform Player;
    [SerializeField] Material SandMaterial;

    private void Update()
    {
        Vector4 pos = Player.position;
        SandMaterial.SetVector("_PlayerPosition", pos);
    }

    private void LateUpdate()
    {
        Vector3 pos = new Vector3(Player.position.x, transform.position.y, Player.position.z);
        transform.position = pos;
    }
}
