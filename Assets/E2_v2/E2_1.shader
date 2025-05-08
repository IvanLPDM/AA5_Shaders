Shader "Unlit/E2"
{
    Properties
    {
        _MainTexA ("Base Texture A", 2D) = "white" {}
        _NormalMapA ("Normal Map A", 2D) = "bump" {}
        _MaskTexA ("Mask Texture A", 2D) = "white" {}

        _MainTexB ("Base Texture B", 2D) = "white" {}
        _NormalMapB ("Normal Map B", 2D) = "bump" {}
        _MaskTexB ("Mask Texture B", 2D) = "white" {}

        _NormalStrengthA ("Normal Strength A", Range(0,2)) = 1
        _NormalStrengthB ("Normal Strength B", Range(0,2)) = 1

        _TilingOffset ("Tiling and Offset", Vector) = (1,1,0,0)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

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
                float4 color : COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                fixed4 color : COLOR;
                UNITY_FOG_COORDS(1)
            };

            sampler2D _MainTexA, _NormalMapA, _MaskTexA;
            sampler2D _MainTexB, _NormalMapB, _MaskTexB;

            float _NormalStrengthA;
            float _NormalStrengthB;
            float4 _TilingOffset; // x, y = tiling; z, w = offset

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                // Apply tiling and offset
                o.uv = v.uv * _TilingOffset.xy + _TilingOffset.zw;
                o.color = v.color;
                UNITY_TRANSFER_FOG(o, o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv;

                float blend = saturate(i.color.r);

                // Sample and process Set A
                fixed4 colA = tex2D(_MainTexA, uv);
                fixed4 maskA = tex2D(_MaskTexA, uv);
                fixed3 normalA = UnpackNormal(tex2D(_NormalMapA, uv));
                normalA = normalize(lerp(fixed3(0,0,1), normalA, _NormalStrengthA));
                float lightA = saturate(dot(normalA, fixed3(0,0,1)));
                fixed3 finalColA = colA.rgb * lightA;

                // Sample and process Set B
                fixed4 colB = tex2D(_MainTexB, uv);
                fixed4 maskB = tex2D(_MaskTexB, uv);
                fixed3 normalB = UnpackNormal(tex2D(_NormalMapB, uv));
                normalB = normalize(lerp(fixed3(0,0,1), normalB, _NormalStrengthB));
                float lightB = saturate(dot(normalB, fixed3(0,0,1)));
                fixed3 finalColB = colB.rgb * lightB;

                // Blend
                fixed3 finalColor = lerp(finalColA, finalColB, blend);
                fixed4 col = fixed4(finalColor, 1.0);

                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}