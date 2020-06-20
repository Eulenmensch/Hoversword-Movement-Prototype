using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class ChasingEnemy : MonoBehaviour, IAttackable
{
    [SerializeField] private float FlingForce;
    [SerializeField] private float FlingHeightFactor;
    [SerializeField] private float SuctionForce;
    [SerializeField] private GameObject Player;
    [SerializeField] private Transform SuctionPoint;
    [SerializeField] private UnityEvent OnHit;

    private Rigidbody RB;

    private void Start()
    {
        RB = GetComponent<Rigidbody>();
    }
    public AttackInteraction GetAttacked(int attackID)
    {
        OnHit.Invoke();
        GetSuckedInFront();
        return new AttackInteraction();
    }

    public void ExitAttacked()
    {
        print( "exitattacked" );
        GetFlung();
    }

    void GetFlung()
    {
        print( "getflung" );
        Vector3 flingDirection = ( Vector3.up * FlingHeightFactor ) + ( transform.position - Player.transform.position ).normalized;
        RB.AddForce( flingDirection * FlingForce );
    }

    void GetSuckedInFront()
    {
        Vector3 suctionDirection = ( SuctionPoint.position - transform.position ).normalized;
        RB.velocity = suctionDirection * SuctionForce;
    }
}
