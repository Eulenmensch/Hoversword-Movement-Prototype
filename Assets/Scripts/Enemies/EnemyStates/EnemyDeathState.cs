using UnityEngine;

public class EnemyDeathState : IEnemyState
{
    Enemy Owner;
    Renderer[] Renderers;

    float DissolveAmount;

    public EnemyDeathState(Enemy _owner)
    {
        this.Owner = _owner;
    }

    public void Enter()
    {
        DissolveAmount = 1;
        Renderers = Owner.GetComponentsInChildren<Renderer>();
        foreach ( var renderer in Renderers )
        {
            renderer.material = Owner.DeathMaterial;
        }
    }
    public void Execute()
    {
        DissolveAmount = Mathf.Lerp( DissolveAmount, 0, Owner.DeathSpeed );
        foreach ( var renderer in Renderers )
        {
            renderer.material.SetFloat( "_DissolveAmount", DissolveAmount );
        }
        if ( DissolveAmount <= 0.001 )
        {
            GameObject.Destroy( Owner.transform.root.gameObject );
        }
    }
    public void Exit() { }
}