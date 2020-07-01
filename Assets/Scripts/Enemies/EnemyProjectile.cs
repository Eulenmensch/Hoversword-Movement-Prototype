using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyProjectile : Projectile, ICollidable
{
    [SerializeField] int _damage;
    [SerializeField] DamageType _damageType;
    [SerializeField] float _slowDownForce;
    [SerializeField] float _moveSpeed;
    [SerializeField] GameObject ExplosionPrefab;

    // Start is called before the first frame update
    protected override void Start()
    {
        base.Start();
    }

    // Update is called once per frame
    protected override void Update()
    {
        base.Update();
    }

    private void FixedUpdate()
    {
        TravelForwards();
    }

    void TravelForwards()
    {
        transform.position += transform.forward * _moveSpeed * Time.deltaTime;
    }

    public CollisionInteraction Collide()
    {
        CollisionInteraction interactionData = new CollisionInteraction( true/*, false*/);
        interactionData.SetDamage( true, _damage, _damageType, _slowDownForce, DamageDirectionType.Velocity );

        Destroy( gameObject );

        return interactionData;
    }

    private void OnTriggerEnter(Collider other)
    {
        Instantiate( ExplosionPrefab, transform.position, Quaternion.identity );
    }
}
