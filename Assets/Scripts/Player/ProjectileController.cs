using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ProjectileController : MonoBehaviour
{
    [SerializeField] private GameObject SeismicChargePrefab;

    private SeismicCharge seismicCharge;
    private bool Previewing;
    // Start is called before the first frame update
    void Start()
    {
        seismicCharge = SeismicChargePrefab.GetComponent<SeismicCharge>();
    }

    // Update is called once per frame
    void Update()
    {
        // if ( Previewing )
        // {
        //     PreviewSeismicCharge();
        // }
    }

    private void PreviewSeismicCharge()
    {
        Gizmos.DrawLine( transform.position, transform.position + transform.forward * ( seismicCharge.TravelTime * ( seismicCharge.MoveSpeed * Time.deltaTime ) ) );
        Gizmos.DrawSphere( transform.position + transform.forward * ( seismicCharge.TravelTime * ( seismicCharge.MoveSpeed * Time.deltaTime ) ), seismicCharge.SuctionRadius );
    }
    public void ShootSeismicCharge()
    {
        Instantiate( SeismicChargePrefab, transform.position, transform.rotation );
    }
    public void SetPreviewing(bool _previewing)
    {
        Previewing = _previewing;
    }
    private void OnDrawGizmos()
    {
        if ( Previewing )
        {
            PreviewSeismicCharge();
        }
    }
}
