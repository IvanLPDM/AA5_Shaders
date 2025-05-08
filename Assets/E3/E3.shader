Shader "Unlit/E3_ColorOnly_TransparentWithNormal"
{
    Properties
    {
        _BaseColor ("Base Color", Color) = (1,1,1,1)
        _NormalMap ("Normal Map", 2D) = "bump" {}
        _NormalStrength ("Normal Strength", Range(0,2)) = 1
    }
    SubShader
    {
        Tags { "Queue"="Transparent" "RenderType"="Transparent" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Cull Off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                UNITY_FOG_COORDS(1)
            };

            sampler2D _NormalMap;
            float4 _NormalMap_ST;

            fixed4 _BaseColor;
            float _NormalStrength;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _NormalMap);
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;

                fixed3 normal = UnpackNormal(tex2D(_NormalMap, uv));
                normal = normalize(lerp(fixed3(0,0,1), normal, _NormalStrength));

                float lighting = saturate(dot(normal, fixed3(0, 0, 1))); // fake front light
                fixed3 litColor = _BaseColor.rgb * lighting;

                fixed4 col = fixed4(litColor, _BaseColor.a); // apply alpha from base color
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}