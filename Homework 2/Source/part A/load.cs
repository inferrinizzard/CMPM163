using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class load : MonoBehaviour
{
    public int num = 0;
    void Update()
    {
        if(num !=0)
            SceneManager.LoadScene(num-1);
        num = 0;
    }

    public void load1(){num=1;}
    public void load2(){num=2;}

}
