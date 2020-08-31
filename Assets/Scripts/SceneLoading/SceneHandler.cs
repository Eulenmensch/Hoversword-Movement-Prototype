using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneHandler : MonoBehaviour
{
    public static SceneHandler Instance { get; private set; }

    //[SerializeField] private string[] allSceneNames;

    [SerializeField] private string[] scenesToLoadOnStart;
    [SerializeField] private bool unloadScenesAtStart;
    private List<string> loadedScenes;

    bool flag;

    [Header("Light")]
    [SerializeField] private bool toggleDirectionalLight = true;
    [SerializeField] private GameObject directionalLight;

    void Awake()
    {
        if (Instance != null && Instance != this)
            Destroy(this);
        else
            Instance = this;
    }

    private void Start()
    {
        loadedScenes = GetLoadedScenes();
        foreach (var name in scenesToLoadOnStart)
        {
            if (!loadedScenes.Contains(SceneManager.GetSceneByName(name).name))
            {
                StartCoroutine(C_LoadScene(name));
            }
        }

        loadedScenes = GetLoadedScenes();
        if (unloadScenesAtStart)
        {
            foreach (var name in loadedScenes)
            {
                if (!scenesToLoadOnStart.Contains(name))
                {
                    UnloadScene(name);
                }
            }
        }
    }

    public void SetLight(bool value)
    {
        Debug.Log($"Set light {value}");
        if (toggleDirectionalLight)
            directionalLight.SetActive(value);
    }

    public void LoadScenes(string[] sceneNames)
    {
        loadedScenes = GetLoadedScenes();

        // if loaded scene is not in scenes to load -> unload it
        foreach (var name in loadedScenes)
        {
            if (Array.IndexOf(sceneNames, name) < 0)
            {
                StartCoroutine(C_UnloadScene(name));
            }
        }

        loadedScenes = GetLoadedScenes();

        // if scene is not loaded -> load it
        foreach (var name in sceneNames)
        {
            if (!loadedScenes.Contains(name))
            {
                StartCoroutine(C_LoadScene(name));
            }
        }
    }

    private List<string> GetLoadedScenes()
    {
        List<string> list = new List<string>();
        int count = SceneManager.sceneCount;
        for (int i = 0; i < count; i++)
        {
            list.Add(SceneManager.GetSceneAt(i).name);
        }
        return list;
    }

    public void LoadScene(string name)
    {
        if (!IsSceneLoaded(name))
            StartCoroutine(C_LoadScene(name));
        else
            Debug.LogError($"Scene '{name}' is already loaded");
    }

    private IEnumerator C_LoadScene(string name)
    {
        //loadedScenes.Add(name);
        yield return SceneManager.LoadSceneAsync(name, LoadSceneMode.Additive);
        Debug.Log($"Scene '{name}' loaded");
    }

    public void UnloadScene(string name)
    {
        if (IsSceneLoaded(name))
            StartCoroutine(C_UnloadScene(name));
        else
            Debug.LogError($"Scene '{name}' is not loaded");
    }

    private IEnumerator C_UnloadScene(string name)
    {
        //loadedScenes.Remove(name);
        yield return SceneManager.UnloadSceneAsync(name, UnloadSceneOptions.UnloadAllEmbeddedSceneObjects);
        Debug.Log($"Scene '{name}' unloaded");
    }

    private bool IsSceneLoaded(string name)
    {
        Scene loadedScene = SceneManager.GetSceneByName(name);
        return loadedScene.isLoaded;
    }
}
