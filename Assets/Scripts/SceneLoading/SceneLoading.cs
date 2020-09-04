using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SceneLoading : MonoBehaviour
{
    [SerializeField] private bool isActive;
    public bool IsActive => isActive;

    [SerializeField] string[] scenesToLoad;
    public string[] ScenesToLoad => scenesToLoad;

    [SerializeField] string activeScene;
    public string ActiveScene => activeScene;

    [SerializeField] private bool activateDirectionalLight;
    public bool ActivateDirectionalLight => activateDirectionalLight;

    [SerializeField] private bool activateFog;
    public bool ActivateFog => activateFog;
}
