using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class CombatController : MonoBehaviour
{
    public Animator CharacterAnimator;
    public Animator BoardAnimator;
    public GameObject HitBox;
    public Vector3 HitBoxSize;
    public LayerMask EnemyLayers;

    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void FixedUpdate()
    {
        if (HitBox != null)
        {
            Collider[] enemies = Physics.OverlapBox(HitBox.transform.position, HitBoxSize / 2.0f, Quaternion.identity, EnemyLayers);
            if (enemies.Length > 0)
            {
                foreach (var enemy in enemies)
                {
                    enemy.GetComponent<EnemyBehaviour>().TakeDamage();
                }
            }
        }
    }

    public void GetAttackInput(InputAction.CallbackContext context)
    {
        if (context.performed)
        {
            CharacterAnimator.SetTrigger("Jump");
            BoardAnimator.SetTrigger("Attack");
        }
    }

    private void OnDrawGizmosSelected()
    {
        if (HitBox == null)
        {
            return;
        }
        Gizmos.DrawWireCube(HitBox.transform.position, HitBoxSize);
    }
}
