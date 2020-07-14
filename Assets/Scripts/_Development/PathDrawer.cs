using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PathDrawer : MonoBehaviour
{
    public Color color = Color.black;
    public float size = 1f;
    public float duration = 1f;

    private Transform _transform;

    private void Awake()
    {
        _transform = transform;
    }

    void Update()
    {
        DebugExtension.DebugPoint(_transform.position, color, size, duration);
    }
}
