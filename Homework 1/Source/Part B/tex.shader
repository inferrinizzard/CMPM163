Shader "Custom/Tex"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Shift ("Shift Amount", int) = 1
	}
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			
			uniform float4 _MainTex_TexelSize; //special value
			uniform float _Shift;
			uniform float _X, _Y;
			
			struct appdata{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v){
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}

			sampler2D _MainTex;

			fixed4 frag (v2f i) : SV_Target{
				float2 size = float2(_MainTex_TexelSize.z, _MainTex_TexelSize.w );
				float2 texel = float2(_MainTex_TexelSize.x, _MainTex_TexelSize.y );
				float x = i.uv.x + texel.x * _X  * (i.uv.y + _Shift);
				float y = i.uv.y + texel.y * _Y  * (i.uv.x + _Shift);
				
				return tex2D(_MainTex, float2(x - (x > 1 || x < 0 ? sign(x) : 0),
																			y - (y > 1 || y < 0 ? sign(y) : 0)));
			}
			ENDCG
		}
	}
}
