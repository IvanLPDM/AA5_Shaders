Shader "Unlit/E2"
{
    Properties
    {
        _BaseTex1("Base Texture 1", 2D) = "white" {}
        _BaseColor1("Base Color 1", Color) = (1,1,1,1)
        _NormalMap1("Normal Map 1", 2D) = "bump" {}
        _Tiling("Tiling", Float) = 1
        _LightDir("Light Direction", Vector) = (0.3, 0.5, 0.8, 0)
        _NormalStrength("Normal Strength", Float) = 1.0

    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            // Texturas y propiedades
            sampler2D _BaseTex1;
            sampler2D _NormalMap1;
            float4 _BaseColor1;
            float _Tiling;
            float4 _LightDir;  
            float _NormalStrength;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldNormal : TEXCOORD1;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv * _Tiling;
                o.worldNormal = normalize(mul(v.normal, (float3x3)unity_ObjectToWorld));
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Sample de la textura base
                fixed4 col = tex2D(_BaseTex1, i.uv) * _BaseColor1;

                // Desempaquetar el mapa normal
                float3 tangentNormal = UnpackNormal(tex2D(_NormalMap1, i.uv));

                tangentNormal *= _NormalStrength;  

                float3 finalNormal = normalize(i.worldNormal + tangentNormal);  

                float3 normalizedLightDir = normalize(_LightDir.xyz);

                // Cálculo de iluminación: Producto punto entre la normal final y la dirección de la luz
                float NdotL = saturate(dot(finalNormal, normalizedLightDir));

                float3 litColor = col.rgb * NdotL;

                return fixed4(litColor, col.a);
            }
            ENDCG
        }
    }

    FallBack "Diffuse"
}