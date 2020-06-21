using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Enemy : MonoBehaviour, IAttackable
{
    public float RangedRange;
    public float ChaseRange;
    public float MeleeRange;
    public float HitStunTime;
    public float DeathSpeed;
    [SerializeField] int MaxHealth;
    [SerializeField] int FlipDamage;
    [SerializeField] int SlashDamage;

    public GameObject Player;
    public Transform IdlePosition;
    public Material DeathMaterial;

    public int Health { get; private set; }

    public EnemyStateMachine StateMachine = new EnemyStateMachine();

    private NavMeshTowBehaviour NavMeshTow;
    private bool HasTakenDamage;

    public virtual void Start()
    {
        StateMachine.ChangeState( new EnemyIdleState( this ) );
        NavMeshTow = GetComponent<NavMeshTowBehaviour>();
        Health = MaxHealth;
    }

    void Update()
    {
        StateMachine.Update();
    }

    public float GetDistanceToPlayer()
    {
        return Vector3.Distance( transform.position, Player.transform.position );
    }

    public void SetNavTarget(Transform _target)
    {
        NavMeshTow.Target = _target;
    }

    public virtual void TakeDamage(AttackType _attackType)
    {
        if ( _attackType == AttackType.Flip )
        {
            Health -= FlipDamage;
        }
        else if ( _attackType == AttackType.Slash )
        {
            Health -= SlashDamage;
        }
        if ( Health < 0 )
        {
            Health = 0;
        }
        HasTakenDamage = true;
    }

    public virtual AttackInteraction GetAttacked(int _amount, AttackType _attackType)
    {
        if ( !HasTakenDamage )
        {
            TakeDamage( _attackType );
        }
        return new AttackInteraction();
    }

    public virtual void ExitAttacked()
    {
        HasTakenDamage = false;
    }
}
