using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public enum PushTypes { Veloctiy }
public interface IPush
{
    (float, PushTypes) Push();
}
