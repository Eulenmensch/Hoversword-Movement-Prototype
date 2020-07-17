using UnityEngine;

public class PlayerDrift : MonoBehaviour
{
    public bool IsCarving { get; private set; }

    [SerializeField] private float CarveForce;          //The additional force that makes the board carve
    [SerializeField] private float CarveFriction;       //The additional force that keeps the board from sliding sideways during a carve
    [SerializeField] private Transform CarveMotor;      //The location where carve force is applied

    private PlayerHandling Handling;
    private Rigidbody RB;

    public void Carve(float _turnInput)
    {
        if (IsCarving)
        {
            //Make the Turn Input scale exponentially to get more of a carving feel when steering
            float scaledTurnInput = Mathf.Pow(_turnInput, 3);
            //Calculate turn force
            Vector3 turnForce = -transform.right * CarveForce * scaledTurnInput;
            //Apply calculated turn force to the rigidbody at the turn motor position
            RB.AddForceAtPosition(turnForce, CarveMotor.position, ForceMode.Acceleration);
            ApplyCarveFriction();
        }
    }

    //FIXME: This method currently duplicates the code of PlayerTurn.ApplySidewaysFriction()
    private void ApplyCarveFriction()
    {
        float sidewaysSpeed = Vector3.Dot(RB.velocity, -transform.right);
        RB.AddForce(transform.right * sidewaysSpeed * CarveFriction, ForceMode.Acceleration);
    }

    public void SetCarving(bool _carving)
    {
        IsCarving = _carving;
    }
}