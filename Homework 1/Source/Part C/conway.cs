using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class conway : MonoBehaviour
{
	Texture2D texA, texB;
	Texture2D inputTex, outputTex;
	RenderTexture rt1;

	Shader cellularAutomataShader, outputTextureShader;

	int width, height;

	Renderer rend;
	int count = 0;

	void Start()
	{
		//print(SystemInfo.copyTextureSupport);

		width = height = 64;

		texA = new Texture2D(width, height, TextureFormat.RGBA32, false);
		texB = new Texture2D(width, height, TextureFormat.RGBA32, false);

		texA.filterMode = FilterMode.Point;
		texB.filterMode = FilterMode.Point;

		for (int i = 0; i < height; i++)
			for (int j = 0; j < width; j++)
				texA.SetPixel(i, j, Random.Range(0.0f, 1.0f) < 0.2f ? Color.black : Color.white);

		texA.Apply(); //copy changes to the GPU

		rt1 = new RenderTexture(width, height, 0, RenderTextureFormat.ARGB32, RenderTextureReadWrite.Linear);

		rend = GetComponent<Renderer>();

		cellularAutomataShader = Shader.Find("Custom/Conway");
		outputTextureShader = Shader.Find("Custom/OutputTexture");
	}


	void Update()
	{
		transform.Rotate(new Vector3(0, Time.deltaTime * 15, 0));

		//set active shader to be a shader that computes the next timestep
		//of the Cellular Automata system
		rend.material.shader = cellularAutomataShader;

		inputTex = count % 10 == 0 ? texA : texB;
		outputTex = count % 10 == 0 ? texB : texA;

		rend.material.SetTexture("_MainTex", inputTex);

		//source, destination, material
		Graphics.Blit(inputTex, rt1, rend.material);
		Graphics.CopyTexture(rt1, outputTex);

		//set the active shader to be a regular shader that maps the current
		//output texture onto a game object
		rend.material.shader = outputTextureShader;
		rend.material.SetTexture("_MainTex", outputTex);

		count++;
	}
}
