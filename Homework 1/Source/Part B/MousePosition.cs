using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MousePosition : MonoBehaviour
{
    Renderer render;

    // Start is called before the first frame update
    void Start()
    {
        render = GetComponent<Renderer>();

        render.material.shader = Shader.Find("Custom/MouseInput");
    }

    // Update is called once per frame
    void Update()
    {
        render.material.SetFloat("_mX", Input.mousePosition.x);
        render.material.SetFloat("_mY", Input.mousePosition.y);


        //Debug.Log(Input.mousePosition);
    }
}
