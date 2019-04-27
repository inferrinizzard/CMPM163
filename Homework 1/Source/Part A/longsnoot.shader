Shader "Custom/longsnoot"
{
	Properties {
		 _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0

		_Amplitude ("Amplitude", Range(0,2)) = 0.4
		_Frequency ("Freqency", Range(1, 8)) = 2
		_Speed ("Speed", Range(0,5)) = 1
	}
	SubShader {
		Tags{ "RenderType"="Opaque" "Queue"="Geometry"}

		CGPROGRAM
		#pragma debug	
		#pragma surface surf Standard fullforwardshadows vertex:vert addshadow
		#pragma target 3.0

		sampler2D _MainTex;
		fixed4 _Color;

		float _Amplitude, _Frequency, _Speed;
		float4 _Metallic, _Glossiness;

		struct Input {float2 uv_MainTex;};

		void vert(inout appdata_full data){
			float4 center = mul(unity_ObjectToWorld, float4(0.0,0.0,0.0,1.0) );
			float4 newPos = data.vertex;
			newPos += float4(cos(_Time.y),0,sin(_Time.y),0);
			newPos.x += sin(length(center - data.vertex) * _Frequency + _Time.y * _Speed) * _Amplitude;
			// newPos.y += sin(normalize(length(center - data.vertex)).y * _Frequency + _Time.y * _Speed) * _Amplitude;
			// newPos.z += sin(normalize(length(center - data.vertex)).z * _Frequency + _Time.y * _Speed) * _Amplitude;
			data.vertex = newPos;
		}

		void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
		ENDCG
	}
	FallBack "Standard"
}