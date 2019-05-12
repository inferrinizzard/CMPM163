using UnityEngine;
using System;

//behaviour which should lie on the same gameobject as the main camera
public class Outline : MonoBehaviour {
    [SerializeField] Material postprocessMaterial;

    void Start(){
        Camera.main.depthTextureMode = Camera.main.depthTextureMode | DepthTextureMode.DepthNormals;
    }

    void OnRenderImage(RenderTexture source, RenderTexture destination){
        Graphics.Blit(source, destination, postprocessMaterial);
    }
}