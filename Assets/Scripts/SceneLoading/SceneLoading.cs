using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SceneLoading : MonoBehaviour
{
    [SerializeField] private bool isActive;
    public bool IsActive => isActive;

    [SerializeField] string[] scenesToLoad;
    public string[] ScenesToLoad => scenesToLoad;

    [SerializeField] private bool activateDirectionalLight;
    public bool ActivateDirectionalLight => activateDirectionalLight;
}
