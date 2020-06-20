public class EnemyStateMachine
{
    public IEnemyState CurrentState { get; private set; }

    public void ChangeState(IEnemyState _newState)
    {
        if ( CurrentState != null )
        {
            CurrentState.Exit();
        }

        CurrentState = _newState;
        CurrentState.Enter();
    }

    public void Update()
    {
        if ( CurrentState != null )
        {
            CurrentState.Execute();
        }
    }
}