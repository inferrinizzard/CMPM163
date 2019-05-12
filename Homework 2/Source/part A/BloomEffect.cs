using UnityEngine;
using System;

[ExecuteInEditMode, ImageEffectAllowedInSceneView]
public class BloomEffect : MonoBehaviour {

	[Range(0, 10)] public float intensity = 1;
	[Range(1, 16)] public int steps = 4;
	[Range(0, 10)] public float threshold = 1;
	[Range(0, 1)] public float softThreshold = 0.5f;

	public Material bloom;
	enum Pass{ filter, down, up, bloom}

	void OnRenderImage (RenderTexture source, RenderTexture destination) {
		float knee = threshold * softThreshold;
		Vector4 filter;
		filter.x = threshold;
		filter.y = filter.x - knee;
		filter.z = 2f * knee;
		filter.w = 0.25f / (knee + 0.00001f);
		bloom.SetVector("_Filter", filter);
		bloom.SetFloat("_Intensity", Mathf.GammaToLinearSpace(intensity));

		int width = source.width / 2;
		int height = source.height / 2;
		RenderTextureFormat format = source.format;

		RenderTexture[] textures = new RenderTexture[steps];
		RenderTexture currentDestination = textures[0] = RenderTexture.GetTemporary(width, height, 0, format);
		Graphics.Blit(source, currentDestination, bloom, (int)Pass.filter);
		RenderTexture currentSource = currentDestination;

		int i = 1;
		for (; i < steps; i++) {
			width = width > 2 ? width / 2 : width;
			height = height > 2 ? height / 2 : height;
			currentDestination = textures[i] = RenderTexture.GetTemporary(width, height, 0, format);
			Graphics.Blit(currentSource, currentDestination, bloom, (int)Pass.down);
			currentSource = currentDestination;
		}

		for (i -= 2; i >= 0; i--) {
			currentDestination = textures[i];
			textures[i] = null;
			Graphics.Blit(currentSource, currentDestination, bloom, (int)Pass.up);
			RenderTexture.ReleaseTemporary(currentSource);
			currentSource = currentDestination;
		}

		bloom.SetTexture("_SourceTex", source);
		Graphics.Blit(currentSource, destination, bloom, (int)Pass.bloom);
		RenderTexture.ReleaseTemporary(currentSource);
	}
}