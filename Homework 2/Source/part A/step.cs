using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class step : MonoBehaviour
{
    public Material hull;
    void Update() { hull.SetFloat("_DissolveAmount", Mathf.PingPong(Time.time/3,1)); }
}
