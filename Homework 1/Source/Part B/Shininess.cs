using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Shininess : MonoBehaviour
{
    //global variables
    Renderer render;
    float s = 32.0f;

    // Start is called before the first frame update
    void Start()
    {
        render = GetComponent<Renderer>();
        render.material.shader = Shader.Find("Custom/Phong");
    }

    // Update is called once per frame
    void Update()
    {

        Color c = new Color(0f, 
            Input.mousePosition.y / Screen.height,
            1f - (Input.mousePosition.y / Screen.height), 
            1f);
        render.material.SetColor("_Color", c);

        if (Input.GetKey("left"))
        {
            print(" pressing left ");
            s -= 1.0f;
        }

        if (Input.GetKey("right"))
        {
            print(" pressing right ");
            s += 1.0f;
        }

        render.material.SetFloat("_Shininess", s);

        print("shininess = " + s + ", color = " + c);
    }
}
