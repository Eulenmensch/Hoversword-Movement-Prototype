using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IShutOff
{
    void ShutOff(Battery machine);

    void Register(Battery machine);

    List<Battery> energySources { get; set; }
}
