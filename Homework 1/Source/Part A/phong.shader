// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/Phong"
{
	Properties{
		_Color ("Color", Color) = (1,1,1,1)
		_SpecularColor ("Specular Colour", Color) = (1,1,1,1)
		_Shininess ("Shininess", float) = 10
	}
	
	SubShader{
		Tags{"RenderType" = "Opaque"}
		LOD 200

		Pass{
			Tags{"LightMode" = "ForwardBase"}
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			uniform float4 _LightColor0;
			
			uniform float4 Color;
			uniform fixed4 _Color;
			uniform fixed4 _SpecularColor;
			uniform fixed _Shininess;

			struct appdata{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f{
				float4 pos : POSITION;
				float3 normal : NORMAL;
				float4 worldPos : TEXCOORD0;
			};

			v2f vert(appdata v){
				v2f o;
				o.worldPos = mul(unity_ObjectToWorld,v.vertex);
				o.normal = normalize(mul(float4(v.normal, 0.0),unity_WorldToObject).xyz);
				o.pos = UnityObjectToClipPos(v.vertex);
				return o;
			}

			fixed4 frag(v2f i):COLOR{
				float3 normal = normalize(i.normal);
				float3 view = normalize(_WorldSpaceCameraPos - i.worldPos.xyz);
				float3 light = _WorldSpaceLightPos0.xyz - i.worldPos.xyz * _WorldSpaceLightPos0.w;
				float3 vert2LightSource = _WorldSpaceLightPos0.xyz - i.worldPos.xyz;
				float3 ambient = UNITY_LIGHTMODEL_AMBIENT.rgb * _Color.rgb;
				float3 diffuse = _LightColor0.rgb * _Color.rgb * max(0.0, dot(normal, light));
				float3 specular = dot(i.normal, light) < 0.0 ? 
				float3(0.0, 0.0, 0.0) : 
				_LightColor0.rgb * _SpecularColor.rgb * pow(max(0.0, dot(reflect(-light, normal), view)), _Shininess);
				return float4(ambient + diffuse + specular, 1.0);
			}

			ENDCG	
		}

		Pass {
			Tags { "LightMode" = "ForwardAdd" } //For every additional light
			Blend One One //Additive blending

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc" //Provides us with light data, camera information, etc

			uniform float4 _LightColor0; //From UnityCG

			sampler2D _Tex; //Used for texture
			float4 _Tex_ST; //For tiling

			uniform float4 _Color, _SpecColor;
			uniform float _Shininess;

			struct appdata{
					float4 vertex : POSITION;
					float3 normal : NORMAL;
					float2 uv : TEXCOORD0;
			};

			struct v2f{
					float4 pos : POSITION;
					float3 normal : NORMAL;
					float2 uv : TEXCOORD0;
					float4 posWorld : TEXCOORD1;
			};

			v2f vert(appdata v)
			{
					v2f o;

					o.posWorld = mul(unity_ObjectToWorld, v.vertex); //Calculate the world position for our point
					o.normal = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz); //Calculate the normal
					o.pos = UnityObjectToClipPos(v.vertex); //And the position
					o.uv = TRANSFORM_TEX(v.uv, _Tex);

					return o;
			}

			fixed4 frag(v2f i) : COLOR
			{
				float3 normal = normalize(i.normal);
				float3 light = _WorldSpaceLightPos0.xyz - i.posWorld.xyz * _WorldSpaceLightPos0.w;
				float3 view = normalize(_WorldSpaceCameraPos - i.posWorld.xyz);
				float3 diffuse = _LightColor0.rgb * _Color.rgb * max(0.0, dot(normal, light)); //Diffuse component
				float3 specular = dot(i.normal, light) < 0.0 ? float3(0.0, 0.0, 0.0) : 
							_LightColor0.rgb * _SpecColor.rgb * pow(max(0.0, dot(reflect(-light, normal), view)), _Shininess);

				return float4(diffuse * tex2D(_Tex, i.uv) + specular, 1.0);
			}
			ENDCG
		}
	}
}