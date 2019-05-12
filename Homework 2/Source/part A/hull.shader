Shader "Custom/hull" {
	    Properties {
        _Color ("Tint", Color) = (0, 0, 0, 1)
        _MainTex ("Texture", 2D) = "white" {}
        [HDR] _Emission ("Emission", color) = (0,0,0)

        _OutlineColor ("Outline Color", Color) = (0, 0, 0, 1)
        _OutlineThickness ("Outline Thickness", Range(0,1)) = 0.1
        _DissolveTex ("Texture", 2D) = "white" {}
		_DissolveAmount ("Dissolve Amount", Range(0, 1)) = 0.5
    }
    SubShader {
        Tags{ "RenderType"="Opaque" "Queue"="Geometry"}

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;
        fixed4 _Color;

        half3 _Emission;
		float _DissolveAmount;
		sampler2D _DissolveTex;

        struct Input {
			float2 uv_MainTex; 
			float2 uv_DissolveTex; 
		};

        void surf (Input i, inout SurfaceOutputStandard o) {
			float dissolve = tex2D(_DissolveTex, i.uv_DissolveTex).r;
			dissolve = dissolve * 0.999;
			float isVisible = dissolve - _DissolveAmount;
			clip(isVisible);

			fixed4 col = tex2D(_MainTex, i.uv_MainTex);
			col *= _Color;

			o.Albedo = dissolve;
			o.Emission = _Emission;
        }
        ENDCG

        Pass{
            Cull Front

            CGPROGRAM

            #include "UnityCG.cginc"

            #pragma vertex vert
            #pragma fragment frag

            fixed4 _OutlineColor;
            float _OutlineThickness;
            float _DissolveAmount;

            struct appdata {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
            };

            struct v2f { float4 position : SV_POSITION; };

            v2f vert(appdata v) {
                v2f o;
                o.position = UnityObjectToClipPos(v.vertex + normalize(v.normal) * _OutlineThickness  * (1-_DissolveAmount));
                return o;
            }

            fixed4 frag(v2f i) : SV_TARGET { return _OutlineColor; }

            ENDCG
        }

    }
    FallBack "Standard"
}