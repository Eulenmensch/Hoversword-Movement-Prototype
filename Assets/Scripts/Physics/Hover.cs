using System;
using UnityEngine;

#if UNITY_EDITOR
using UnityEditor;
#endif

[RequireComponent( typeof( Rigidbody ) )]
public class Hover : MonoBehaviour
{
    #region Settings
    [Header( "Hover Settings" )]
    [SerializeField] private float HoverForce;                  //The force that pushes the board upwards
    //TODO:public float AnticipativeHoverForce;                 //The force that smoothes out sudden changes in ground gradient
    [SerializeField] private float HoverHeight;                 //The ideal height at which the board wants to hover

    [Header( "Ground Stick Settings" )]
    [SerializeField] private bool StickToGround;                //Whether the board should stick to the ground when grounded
    [SerializeField] private float GroundStickForce;            //The force applied inverse to ground normal
    [SerializeField] private float GroundStickHeight;           //The maximum height at which the ground stick force is applied
    [SerializeField] private LayerMask GroundMask;              //The layer mask that determines what counts as ground

    [Header( "Hover Point Settings" )]
    [SerializeField] private GameObject HoverPointPrefab;       //The hover point prefab
    [SerializeField] private GameObject HoverPointContainer;    //The GameObject to which the generated hoverpoints are childed
    [SerializeField] private BoxCollider HoverArea;             //The area in which a hoverpoint array is generated
    [SerializeField] private int HoverPointRows;                //how many hoverpoint rows are generated
    [SerializeField] private int HoverPointColumns;             //how many hoverpoint columns are generated

    [Header( "PID Controller Settings" )]
    [SerializeField, Range( 0.0f, 1.0f )] private float ProportionalGain;  //A tuning value for the proportional error correction
    [SerializeField, Range( 0.0f, 1.0f )] private float IntegralGain;      //A tuning value for the integral error correction
    [SerializeField, Range( 0.0f, 1.0f )] private float DerivativeGain;    //A tuning value for the derivative error correction

#if UNITY_EDITOR
    [Header( "Debug Settings" )]
    [SerializeField] private bool Debugging;
    [SerializeField] private GUIStyle DebugTextStyle;
    [SerializeField] private Gradient DebugGradient;
#endif
    #endregion

    private Rigidbody RB;               //A reference to the board's rigidbody
    private Transform[] HoverPoints;   //The points from which ground distance is measured and where hover force is applied
    private PIDController[] PIDs;       //References to the PIDController class that handles error correction and smoothens out the hovering
    private IMove Movement;             //Reference to a possibly attached component that implements IMove

    void Start()
    {
        RB = GetComponent<Rigidbody>();
        Movement = GetComponent<IMove>();

        //Initialize an array to contain all hover points
        HoverPoints = new Transform[HoverPointRows * HoverPointColumns];
        GenerateHoverPoints( HoverArea, HoverPointColumns, HoverPointRows );

        CreatePIDs();
    }

    void FixedUpdate()
    {
        ApplyHoverForces();
        ApplyGroundStickForce();
    }

    private void GenerateHoverPoints(BoxCollider _area, int _columns, int _rows)
    {
        float columnSpacing = _area.size.x / ( _columns - 1 );
        float rowSpacing = _area.size.z / ( _rows - 1 );
        Vector3 rowOffset = new Vector3( 0, 0, rowSpacing );

        for ( int i = 0; i < _columns; i++ )
        {
            Vector3 columnHead = new Vector3(
                ( _area.center.x - _area.extents.x ) + ( columnSpacing * i ),
                _area.center.y,
                _area.center.z + _area.extents.z
            );

            for ( int j = 0; j < _rows; j++ )
            {
                Vector3 hoverPointPos = columnHead - ( rowOffset * j );
                hoverPointPos = transform.TransformPoint( hoverPointPos );
                GameObject newHoverPoint = Instantiate( HoverPointPrefab, hoverPointPos, Quaternion.identity, HoverPointContainer.transform );
                HoverPoints[( i * _rows ) + j] = newHoverPoint.transform;
            }
        }
    }
    private void CreatePIDs()
    {
        //Create an instance of the PIDController class for each hover point
        PIDs = new PIDController[HoverPoints.Length];
        for ( int i = 0; i < HoverPoints.Length; i++ )
        {
            PIDs[i] = new PIDController( ProportionalGain, IntegralGain, DerivativeGain );
        }
    }

    private void ApplyHoverForces()
    {
        foreach ( Transform hoverPoint in HoverPoints )
        {
            Vector3 hoverPointPos = hoverPoint.position;
            RaycastHit hit;

            if ( HoverRay( hoverPointPos, out hit ) )
            {
                float actualHeight = hit.distance;
                Vector3 groundNormal = hit.normal;

                //Use the respective PID controller to calculate the percentage of hover force to be used
                float forcePercent = PIDs[Array.IndexOf( HoverPoints, hoverPoint )].Control( HoverHeight, actualHeight );

                //calculate the adjusted force in the direction of the ground normal
                Vector3 adjustedForce = HoverForce * forcePercent * groundNormal;

                //Add the force to the rigidbody at the respective hoverpoint's position
                RB.AddForceAtPosition( adjustedForce, hoverPointPos, ForceMode.Acceleration );
            }
        }
    }

    private void ApplyGroundStickForce()
    {
        Ray groundStickRay = new Ray( transform.position, -transform.up );
        RaycastHit hit;
        if ( StickToGround )
        {
            if ( Physics.Raycast( groundStickRay, out hit, GroundStickHeight, GroundMask ) )
            {
                Vector3 force = Vector3.zero;
                //Checks if the hovering object implements IMove
                if ( Movement != null )
                {
                    force = -hit.normal * GroundStickForce * ( RB.velocity.magnitude / Movement.MaxSpeed );
                }
                else if ( Movement == null )
                {
                    force = -hit.normal * GroundStickForce;
                }
                RB.AddForce( force, ForceMode.Acceleration );
            }
        }
    }

    private bool HoverRay(Vector3 _hoverPointPosition, out RaycastHit _hit)
    {
        RaycastHit hit;
        bool ray = Physics.Raycast( _hoverPointPosition, -transform.up, out hit, HoverHeight, GroundMask );
        _hit = hit;
        return ray;
    }

    #region Editor
#if UNITY_EDITOR
    private void OnDrawGizmos()
    {
        if ( Debugging )
        {
            if ( HoverPoints != null )
            {
                foreach ( var hoverPoint in HoverPoints )
                {
                    Gizmos.DrawWireSphere( hoverPoint.position, 0.1f );

                    RaycastHit hit;
                    if ( HoverRay( hoverPoint.position, out hit ) )
                    {
                        Gizmos.color = DebugGradient.Evaluate( hit.distance / HoverHeight );
                        Gizmos.DrawSphere( hit.point, 0.07f );
                        Debug.DrawLine( hoverPoint.position, hoverPoint.position - transform.up * hit.distance, DebugGradient.Evaluate( hit.distance / HoverHeight ) );
                    }
                    Gizmos.color = Color.white;
                }
            }
        }
    }
    private void OnGUI()
    {
        if ( Debugging )
        {
            foreach ( var hoverPoint in HoverPoints )
            {
                RaycastHit hit;
                if ( HoverRay( hoverPoint.position, out hit ) )
                {
                    string text = ( hit.distance / HoverHeight ).ToString( "0.00" ); //the ratio of intended height and actual height
                    Handles.Label( hoverPoint.position - transform.up * ( hit.distance / 2 ), text, DebugTextStyle );
                }
            }
        }
    }
#endif
    #endregion
}
