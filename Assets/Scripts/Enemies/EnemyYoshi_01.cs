using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class EnemyYoshi_01 : Enemy
{
    [SerializeField] private float FlingForce;
    [SerializeField] private float FlingHeightFactor;
    [SerializeField] private float SuctionForce;
    [SerializeField] private Transform SuctionPoint;
    [SerializeField] private float[] CrackSteps;
    [SerializeField] private GameObject CrackableHead;  //Crackhead v_v

    private Rigidbody RB;
    private Renderer HeadRenderer;

    public override void Start()
    {
        base.Start();
        RB = GetComponent<Rigidbody>();
        HeadRenderer = CrackableHead.GetComponent<Renderer>();
        HeadRenderer.material.SetFloat("_DamagedAmount", CrackSteps[CrackSteps.Length - 1]);
    }

#if UNITY_EDITOR
    private void OnDrawGizmos()
    {
        Handles.color = Color.cyan;
        Handles.DrawWireDisc(transform.position, transform.up, RangedRange);
        Handles.color = Color.magenta;
        Handles.DrawWireDisc(transform.position, transform.up, ChaseRange);
        Handles.color = Color.green;
        Handles.DrawWireDisc(transform.position, transform.up, MeleeRange);
    }
#endif

    public void EnterGetHitState() //gets called by a unity event FIXME: proper C# event manager?
    {
        if (!(StateMachine.CurrentState is EnemyGetHitState))
        {
            StateMachine.ChangeState(new EnemyGetHitState(this, StateMachine.CurrentState));
        }
    }

    public override void TakeDamage(AttackTypes _attackType)
    {
        base.TakeDamage(_attackType);
        IncreaseHitCracks();
    }

    public override AttackInteraction GetAttacked(int _amount, AttackTypes _attackType)
    {
        base.GetAttacked(_amount, _attackType);
        EnterGetHitState();
        GetSuckedInFront();
        return new AttackInteraction();
    }

    public override void ExitAttacked()
    {
        print("flingaling");
        base.ExitAttacked();
        GetFlung();
    }

    void GetSuckedInFront()
    {
        Vector3 suctionDirection = (SuctionPoint.position - transform.position).normalized;
        RB.velocity = suctionDirection * SuctionForce;
    }

    void GetFlung()
    {
        print("getflung");
        Vector3 flingDirection = (Player.transform.forward + (Vector3.up * FlingHeightFactor)).normalized;
        RB.AddForce(flingDirection * FlingForce);
    }

    void IncreaseHitCracks()
    {
        if (Health > 0)
        {
            HeadRenderer.material.SetFloat("_DamagedAmount", CrackSteps[Health - 1]);
        }
    }
}
