using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FootIKTargetPrediction : MonoBehaviour
{
    public float castHeight;
    public float offset;
    public LayerMask layerMask;
    public float yPos;
    public RaycastHit hit;

    void FixedUpdate()
    {
        Vector3 castPoint = new Vector3( transform.position.x, transform.parent.position.y + castHeight, transform.position.z );
        if ( Physics.Raycast( castPoint, Vector3.down, out hit, Mathf.Infinity, layerMask ) )
        {
            yPos = hit.point.y + offset;
            transform.position = new Vector3( transform.position.x, yPos, transform.position.z );
        }
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.magenta;
        Gizmos.DrawCube( transform.position, Vector3.one * 0.4f );
    }
}
