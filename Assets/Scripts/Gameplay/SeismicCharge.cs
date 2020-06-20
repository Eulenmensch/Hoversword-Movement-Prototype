using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SeismicCharge : MonoBehaviour
{
    public float MoveSpeed;
    public float TravelTime;
    [SerializeField] private float SuctionTime;
    public float SuctionRadius;
    [SerializeField] private float SuctionForce;
    [SerializeField] private LayerMask EnemyLayers;

    private float TravelTimer;
    private float SuctionTimer;

    // Start is called before the first frame update
    void Start()
    {
        TravelTimer = 0;
    }

    // Update is called once per frame
    void Update()
    {
        if ( TravelTimer < TravelTime )
        {
            TravelForwards();
        }
        TravelTimer += Time.deltaTime;
        if ( TravelTimer >= TravelTime )
        {
            SuctionTimer += Time.deltaTime;
            SuckNearbyEnemies();

            if ( SuctionTimer >= SuctionTime )
            {
                Destroy( gameObject );
            }
        }
    }

    void TravelForwards()
    {
        transform.position += transform.forward * MoveSpeed * Time.deltaTime;
    }

    void SuckNearbyEnemies()
    {
        Collider[] nearbyEnemies = Physics.OverlapSphere( transform.position, SuctionRadius, EnemyLayers );
        if ( nearbyEnemies.Length > 0 )
        {
            print( "collided" );
            foreach ( var enemy in nearbyEnemies )
            {
                print( enemy.gameObject.name );
                Rigidbody enemyRB = enemy.gameObject.GetComponent<Rigidbody>();
                Vector3 suctionDirection = ( transform.position - enemy.transform.position ).normalized;
                enemyRB.velocity = suctionDirection * SuctionForce;
            }
        }
    }
}
