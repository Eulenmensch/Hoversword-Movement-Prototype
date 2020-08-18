using UnityEngine;

[RequireComponent( typeof( Rigidbody ) )]
public class PlayerAirControl : MonoBehaviour
{
    [SerializeField] private float StabilizationForce;          //The force exerted on the body to orient it upright
    [SerializeField] private float StabilizationSpeed;          //The time it takes for the board to return to an upright state
    [SerializeField] private float AirControlForce;             //The angular force exerted on the body by player input
    [SerializeField] private float GroundPitchControlForce;
    [SerializeField] private float MinimumGroundPitchInput;
    [SerializeField] private float MinimumAirPitchInput;        //The input amount up from which the character stops being stabilized

    private Rigidbody RB;

    private void Start()
    {
        RB = GetComponent<Rigidbody>();
    }

    public void AirControl(float _pitchInput, bool _grounded, bool _dashing)
    {
        //Define the axis we use for pitch rotation
        Vector3 pitchAxis = transform.right;
        //Define the axis we use for roll rotation
        Vector3 rollAxis = transform.forward;
        //Define the up rotation the body is rotated to
        Vector3 upDirection = Vector3.up;

        if ( !_grounded || _dashing )
        {
            ControlAngularMotion( pitchAxis, _pitchInput );
            if ( _pitchInput <= MinimumAirPitchInput && _pitchInput >= -MinimumAirPitchInput )
            {
                StabilizeAngularMotion( rollAxis, upDirection );
            }
        }

        //FIXME: this happens on the ground which kind of goes against the scope of this class
        else if ( _grounded )
        {
            if ( Mathf.Abs( _pitchInput ) > MinimumGroundPitchInput )
            {
                ControlAngularMotion( pitchAxis, _pitchInput * GroundPitchControlForce );
            }
        }
    }
    //Adds torque to the rigidbody to make it return to a upright position.
    //Takes an axis to rotate around as well as the up direction as arguments
    private void StabilizeAngularMotion(Vector3 _rotationAxis, Vector3 _upDirection)
    {
        //Do some spooky voodoo shit http://answers.unity.com/answers/10426/view.html
        float predictedUpAngle = RB.angularVelocity.magnitude * Mathf.Rad2Deg * StabilizationForce / StabilizationSpeed;
        //Calculate the necessary rotation
        Vector3 predictedUp = Quaternion.AngleAxis( predictedUpAngle, RB.angularVelocity ) * transform.up;
        //Do we need to rotate cw or ccw? In which plane?
        Vector3 torqueVector = Vector3.Cross( predictedUp, _upDirection );
        //Only affect the axis given by the attribute
        torqueVector = Vector3.Project( torqueVector, _rotationAxis );

        //Add the torque force to the body
        RB.AddTorque( torqueVector * StabilizationSpeed * StabilizationSpeed, ForceMode.Acceleration );
    }

    //Adds torque to the rigidbody based on the player Input
    private void ControlAngularMotion(Vector3 _rotationAxis, float _controlInput)
    {
        Vector3 controlForce = _rotationAxis * AirControlForce * _controlInput;
        RB.AddTorque( controlForce, ForceMode.Acceleration );
    }
}