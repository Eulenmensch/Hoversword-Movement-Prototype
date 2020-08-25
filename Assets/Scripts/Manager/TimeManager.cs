using DG.Tweening;
using System;
using System.Collections;
using System.Collections.Generic;
#if UNITY_EDITOR
using UnityEditor;
#endif
using UnityEngine;
using UnityEngine.SceneManagement;

public class TimeManager : MonoBehaviour
{
    public static TimeManager Instance { get; private set; }

    [Header("Time")]
    [ShowOnly, SerializeField] private float gameTime;

    [Header("TimeScale")]
    [ShowOnly, SerializeField] private float _gameTimeScale = 1f;
    [ShowOnly, SerializeField] private float _ingameTimeScale = 1f;
    [ShowOnly, SerializeField] private float _timeScale;

    private Tween _timeTween;
    [Header("Aiming Bullet Time")]
    [SerializeField] private float _bulletTimescaleAiming;
    [SerializeField] private float _bulletTimeAimingFadeInDuration;
    [SerializeField] private float _bulletTimeAimingFadeOutDuration;
    [SerializeField] Ease _bulletTimeAimingEaseIn;
    [SerializeField] Ease _bulletTimeAimingEaseOut;

    [Header("Aiming Bullet Time")]
    [SerializeField] private float _bulletTimescaleDeath;
    [SerializeField] private float _bulletTimeDeathFadeInDuration;
    [SerializeField] Ease _bulletTimeDeathEaseIn;

    // Debugging timeScale
    private float[] timeScaleSteps = new float[] { 0.25f, 0.5f, 0.75f, 1f, 1.5f, 2f, 3f, 4f, 5f };
    private int currentTimeScaleStep = 3;

    [Header("Fixed Update Frame Stopping")]
    public bool stopFrame;
    public int frameStep;
    int currentFrame = 0;
    //[ShowOnly, SerializeField]
    //public int frames = 0;
    [ShowOnly, SerializeField]
    int fixedframes = 0;

    void Awake()
    {
        if (Instance != null && Instance != this)
        {
            Destroy(this);
        }
        else
        {
            Instance = this;
        }
    }

    void Update()
    {
        gameTime = Time.time;

        if (Input.GetKeyDown(KeyCode.R))
        {
            SceneManager.LoadScene(SceneManager.GetActiveScene().name);
        }

        if (Input.GetKeyDown(KeyCode.Escape))
        {
            Application.Quit();
        }


        // Pause Time with F3
        if (Input.GetKeyDown(KeyCode.F6))
        {
            if (_gameTimeScale != 0)
            {
                _gameTimeScale = 0;
            }
            else
            {
                _gameTimeScale = timeScaleSteps[currentTimeScaleStep];
            }
        }


        // Make Time run faster and slower with F1 and F2
        if (Input.GetKeyDown(KeyCode.F5))
        {
            currentTimeScaleStep = currentTimeScaleStep > 0 ? currentTimeScaleStep - 1 : 0;

            _gameTimeScale = timeScaleSteps[currentTimeScaleStep];
        }

        if (Input.GetKeyDown(KeyCode.F7))
        {
            currentTimeScaleStep = currentTimeScaleStep < timeScaleSteps.Length - 1 ? currentTimeScaleStep + 1 : timeScaleSteps.Length - 1;
            _gameTimeScale = timeScaleSteps[currentTimeScaleStep];
        }

        Time.timeScale = _timeScale = _gameTimeScale * _ingameTimeScale;
    }

    private void FixedUpdate()
    {
        fixedframes++;

        if (stopFrame/* && useFixedUpdate*/)
        {
            currentFrame++;

            if (currentFrame >= frameStep)
            {
#if UNITY_EDITOR
                EditorApplication.isPaused = true;
#endif
                currentFrame = 0;
            }
        }

    }

    internal void StartAim()
    {
        _timeTween?.Kill();
        _timeTween = DOTween.To(() => _ingameTimeScale, x => _ingameTimeScale = x, _bulletTimescaleAiming, _bulletTimeAimingFadeInDuration)
            .SetEase(_bulletTimeAimingEaseIn).SetUpdate(true);
    }

    internal void StopAim()
    {
        _timeTween?.Kill();
        _timeTween = DOTween.To(() => _ingameTimeScale, x => _ingameTimeScale = x, 1f, _bulletTimeAimingFadeOutDuration)
            .SetEase(_bulletTimeAimingEaseOut).SetUpdate(true);
    }

    public void StartDeath()
    {
        _timeTween?.Kill();
        _timeTween = DOTween.To(() => _ingameTimeScale, x => _ingameTimeScale = x, _bulletTimescaleDeath, _bulletTimeDeathFadeInDuration)
            .SetEase(_bulletTimeDeathEaseIn).SetUpdate(true);
    }

    public void StopDeath()
    {
        _timeTween?.Kill();
        _ingameTimeScale = 1f;
    }
}
