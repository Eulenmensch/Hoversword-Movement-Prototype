using System.Collections.Generic;
using UnityEngine;

public class CustomFPS : MonoBehaviour
{
    private class Snapshot
    {
        public Transform Transform;
        public Vector3 Position;
        public Quaternion Rotation;
        public Vector3 Scale;

        public Snapshot(Transform transform)
        {
            this.Transform = transform;
            this.Update();
        }

        public void Update()
        {
            this.Position = this.Transform.localPosition;
            this.Rotation = this.Transform.localRotation;
            this.Scale = this.Transform.localScale;
        }
    }

    private Dictionary<int, Snapshot> Snapshots = new Dictionary<int, Snapshot>();
    private float UpdateTime = 0f;

    [Range(1, 60)] public int FPS = 20;

    private void LateUpdate()
    {
        if (Time.unscaledTime - this.UpdateTime > 1f / this.FPS)
        {
            this.SaveSnapshot(transform);
            this.UpdateTime = Time.unscaledTime;
        }

        foreach (KeyValuePair<int, Snapshot> item in this.Snapshots)
        {
            if (item.Value.Transform != null)
            {
                item.Value.Transform.localPosition = item.Value.Position;
                item.Value.Transform.localRotation = item.Value.Rotation;
                item.Value.Transform.localScale = item.Value.Scale;
            }
        }
    }

    private void SaveSnapshot(Transform parent)
    {
        if (parent == null) return;
        int childrenCount = parent.childCount;

        for (int i = 0; i < childrenCount; ++i)
        {
            Transform target = parent.GetChild(i);
            int uid = target.GetInstanceID();

            this.Snapshots[uid] = new Snapshot(target);
            this.SaveSnapshot(target);
        }
    }
}