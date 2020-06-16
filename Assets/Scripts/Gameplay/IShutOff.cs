using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IShutOff
{
    void ShutOff(Machine machine);

    void Register(Machine machine);

    List<Machine> energySources { get; set; }
}
