
Shader "Custom/Hill"
{
    Properties
    {   
        _Color ("Color", Color) = (1, 1, 1, 1) 
        _Shininess ("Shininess", Float) = 32 
        _SpecColor ("Specular Color", Color) = (1, 1, 1, 1) 
        _DirtTex ("DirtTexture", 2D) = "white" {}
        _GrassTex ("GrassTexture", 2D) = "white" {}
        _SnowTex ("SnowTexture", 2D) = "white" {}

        _Speed ("Speed", Range(0.001, .2)) = .01
        _Height ("Height", Float) = 2

		_Roughness ("Roughness", Range(1, 8)) = 3
		_Persistance ("Persistance", Range(0, 1)) = 0.4
    }
    
    SubShader
    {
        Pass {
            Tags { "LightMode" = "ForwardAdd" } 
          
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Random.cginc"
           
            uniform float4 _LightColor0; 
            uniform float4 _Color, _SpecColor;
            uniform float _Shininess;  

            uniform sampler2D _DirtTex;
            uniform sampler2D _SnowTex;
            uniform sampler2D _GrassTex;  

            float _Speed, _Height; 
            float _Roughness, _Persistance;
            
            struct appdata {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct v2f {
                float4 vertex : SV_POSITION;
                float3 normal : NORMAL;       
                float2 uv : TEXCOORD0;
                float3 vertexInWorldCoords : TEXCOORD1;
                float heightVal : TEXCOORD2;
            };

            float easeIn(float interpolator) { return interpolator * interpolator; }
            float easeOut(float interpolator) { return 1 - easeIn(1 - interpolator); }
            float easeInOut(float interpolator) { return lerp(easeIn(interpolator), easeOut(interpolator), interpolator); }

            float perlinNoise(float3 value){
                float3 fraction = frac(value);
                float interpolatorX = easeInOut(fraction.x), interpolatorY = easeInOut(fraction.y), interpolatorZ = easeInOut(fraction.z);

                float3 cellNoiseZ[2];
                [unroll]
                for(int z=0;z<=1;z++){
                    float3 cellNoiseY[2];
                    [unroll]
                    for(int y=0;y<=1;y++){
                        float3 cellNoiseX[2];
                        [unroll]
                        for(int x=0;x<=1;x++){
                            float3 cell = floor(value) + float3(x, y, z);
                            float3 cellDirection = rand3dTo3d(cell) * 2 - 1;
                            float3 compareVector = fraction - float3(x, y, z);
                            cellNoiseX[x] = dot(cellDirection, compareVector);
                        }
                        cellNoiseY[y] = lerp(cellNoiseX[0], cellNoiseX[1], interpolatorX);
                    }
                    cellNoiseZ[z] = lerp(cellNoiseY[0], cellNoiseY[1], interpolatorY);
                }
                float3 noise = lerp(cellNoiseZ[0], cellNoiseZ[1], interpolatorZ);
                return noise;
            }

            float sampleLayeredNoise(float3 value){
                float noise = 0, frequency = 1, factor = 1;

                [unroll]
                for(int i=0;i<4;i++){
                    noise = noise + perlinNoise(value * frequency + i * 0.72354) * factor;
                    factor *= _Persistance;
                    frequency *= _Roughness;
                }

                return noise;
            }
 
           v2f vert(appdata v) { 
                v2f o;
                float3 dPos = float3(_Time.y * _Speed, _Time.y * _Speed, _Time.y * _Speed);
                float3 vPrime = v.vertex; 
                float4 newpos = float4(v.vertex.x, sampleLayeredNoise(vPrime + dPos) * _Height, v.vertex.z, 1);
                o.vertexInWorldCoords = mul(unity_ObjectToWorld, newpos);
                o.normal = UnityObjectToWorldNormal(v.normal); 
                o.vertex = UnityObjectToClipPos(newpos); 
                o.uv = v.uv;
                o.heightVal = sampleLayeredNoise(vPrime + dPos) * _Height+.15;
                
                return o;
           }

           fixed4 frag(v2f i) : SV_Target {
                float3 P = i.vertexInWorldCoords.xyz;
                float3 N = normalize(i.normal);
                float3 V = normalize(_WorldSpaceCameraPos - P), L = normalize(_WorldSpaceLightPos0.xyz - P);
                float3 H = normalize(L + V);
                
                float3 Kd = _Color.rgb; 
                float3 Ka = UNITY_LIGHTMODEL_AMBIENT.rgb; 
                float3 Ks = _SpecColor.rgb, Kl = _LightColor0.rgb; 
                
                float3 ambient = Ka;
                float diffuseVal = max(dot(N, L), 0);
                float3 diffuse = Kd * Kl * diffuseVal;
                float specularVal = diffuseVal <= 0 ? 0 :pow(max(dot(N,H), 0), _Shininess);
                float3 specular = Ks * Kl * specularVal;
                
                float3 lightColor = float3(ambient + diffuse + specular);
               
                float3 dirt = tex2D(_DirtTex, i.uv).rgb, grass = tex2D(_GrassTex, i.uv).rgb, snow = tex2D(_SnowTex, i.uv).rgb;
                float3 textureColor = i.heightVal < 0.5 ? lerp(snow, dirt, i.heightVal * 2) : lerp(dirt, grass, i.heightVal * 2 - 1);
                return float4(lerp(textureColor, lightColor, 0.25), 1.0);
            }
            ENDCG
        }
    }
}
