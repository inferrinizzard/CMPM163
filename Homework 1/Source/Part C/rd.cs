

using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PingPong_ReactionDiffusion : MonoBehaviour
{

	Texture2D texA, texB;

	Texture2D inputTex, outputTex;

	RenderTexture offscreenBuffer;

	Shader reactionDiffusionShader, outputTextureShader;

	static int width = 200, height = 200;

	Renderer rend;
	int count = 0;

	float[,,] grid, next;


	void Start()
	{

		texA = new Texture2D(width, height, TextureFormat.RGBAFloat, false);
		texB = new Texture2D(width, height, TextureFormat.RGBAFloat, false);

		texA.filterMode = FilterMode.Point;
		texB.filterMode = FilterMode.Point;

		int floatArraySize = width * height;
		Color[] floatArray1 = new Color[floatArraySize], floatArray2 = new Color[floatArraySize];

		for (int i = 0; i < floatArraySize; i++)
		{
			floatArray1[i].r = 1.0f;
			floatArray1[i].g = 0.0f;
			floatArray1[i].b = 0.0f;
			floatArray1[i].a = 1.0f;

			floatArray2[i].r = 1.0f;
			floatArray2[i].g = 0.0f;
			floatArray2[i].b = 0.0f;
			floatArray2[i].a = 1.0f;
		}

		//tempTex2D.SetPixels(floatArray1, 0);
		texA.SetPixels(floatArray1, 0);
		//texB.SetPixels(floatArray2, 0);

		//fill in block of color
		Color seedColor = new Color();

		seedColor.r = 0.0f;
		seedColor.g = 1.0f;
		seedColor.b = 0.0f;
		seedColor.a = 1.0f;

		int numSeeds = 20;
		for (int i = 0; i < numSeeds; i++)
		{
			int seedSize = Random.Range(5, 25);
			int rw = Random.Range(seedSize / 2, width - seedSize / 2);
			int rh = Random.Range(seedSize / 2, height - seedSize / 2);

			for (int x = rw - seedSize / 2; x < rw + seedSize / 2; x++)
				for (int y = rh - seedSize / 2; y < rh + seedSize / 2; y++)
					texA.SetPixel(x, y, seedColor);
		}

		texA.Apply(); //copies our changes made here on the CPU to the GPU so that they are made available to our shaders

		offscreenBuffer = new RenderTexture(width, height, 0, RenderTextureFormat.ARGBFloat, RenderTextureReadWrite.Linear);
		offscreenBuffer.filterMode = FilterMode.Point;

		rend = GetComponent<Renderer>();

		reactionDiffusionShader = Shader.Find("Custom/RenderToTexture_RD");
		outputTextureShader = Shader.Find("Custom/OutputTexture_RD");

		//print(" supports TextureFormat.RGBAFloat?  " + SystemInfo.SupportsTextureFormat(TextureFormat.RGBAFloat));
		//print(" supports RenderTextureFormat.ARGBFloat?: " + SystemInfo.SupportsTextureFormat(TextureFormat.RGBAFloat));

	}

	void Update()
	{
		inputTex = count % 10 == 0 ? texA : texB;
		outputTex = count % 10 == 0 ? texB : texA;

		//set active shader to be a shader that computes the next timestep
		//of the Cellular Automata system
		rend.material.shader = reactionDiffusionShader;

		//rend.material.SetTexture("_MainTex", inputTex); //redundant here since the Blit command assigns inputTex to the default _MainTex

		//source, destination, material (with shader bound to it)
		Graphics.Blit(inputTex, offscreenBuffer, rend.material);
		Graphics.CopyTexture(offscreenBuffer, outputTex);


		//// to copy from GPU to CPU (slow)
		//RenderTexture.active = rt1;
		//Texture2D tex = new Texture2D(rt1.width, rt1.height, TextureFormat.RGBAFloat, false);
		//tex.ReadPixels(new Rect(0, 0, rt1.width, rt1.height), 0, 0);
		//tex.Apply();
		//Color[] pixA = tex.GetPixels(1, 1, 1, 1);
		//print("pixel outputTex = " + pixA[0].r); //checking to see if output texture holds a floating point variable instead of a uint8 color val



		//set the active shader to be a regular shader that maps the current
		//output texture onto a game object
		rend.material.shader = outputTextureShader;
		rend.material.SetTexture("_MainTex", outputTex);


		count++;

	}
}
