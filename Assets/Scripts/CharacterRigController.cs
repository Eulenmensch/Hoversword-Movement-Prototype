using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using DG.Tweening;

public class CharacterRigController : MonoBehaviour
{
    private Vector3 MoveBy;
    [SerializeField] private float MoveDuration;

    void Start()
    {

    }

    void Update()
    {
        MoveRoot();
    }

    private void MoveRoot()
    {
        this.transform.DOLocalMove( MoveBy * 0.3f, MoveDuration, false );
    }
    public void SetMoveInput(Vector2 move)
    {
        MoveBy = new Vector3( move.x, -0.2f, 0 );
        //MoveBy = transform.TransformDirection( MoveBy );
    }
}
