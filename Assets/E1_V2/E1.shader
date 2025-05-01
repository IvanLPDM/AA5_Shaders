Shader "Unlit/E1"
{
    Properties
    {
        _BaseColor("HDR Color", Color) = (1,1,1,1)
        _MainTex("Main Texture", 2D) = "white" {}
        _Tiling("Tiling", Vector) = (1,1,0,0)
        _Speed("Texture Speed", Vector) = (0.1, 0.1, 0, 0)

        //Fresnel
        _PowerGlow("Power Glow", Float) = 1

        //Geometry Intersection
        _IntersectionDepth("Intersection Depth", Float) = 0.1

        _Alpha("Alpha", Range(0,1)) = 1
        [Enum(Alpha,0,Additive,1)] _BlendMode("Blend Mode", Float) = 0
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        LOD 100
        ZWrite Off
        Blend SrcAlpha OneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #pragma multi_compile _ CAMERA_DEPTH_TEXTURE
            #include "UnityCG.cginc"
            

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 viewDir : TEXCOORD1;
                float3 worldNormal : TEXCOORD2;
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD3;
                float4 screenPos : TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Speed;
            float4 _BaseColor;
            float _PowerGlow;
            float _Alpha;
            float _IntersectionDepth;
            sampler2D _CameraDepthTexture;

            v2f vert (appdata v)
            {
                v2f o;

                float2 uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uv = uv + _Speed.xy * _Time.y;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = normalize(UnityObjectToWorldNormal(v.normal));
                float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.viewDir = normalize(_WorldSpaceCameraPos - worldPos);

                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                o.screenPos = ComputeScreenPos(o.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 texColor = tex2D(_MainTex, i.uv);

                // Base color 
                texColor.rgb *= _BaseColor.rgb;

                // Fresnel
                float fresnel = pow(1.0 - saturate(dot(normalize(i.viewDir), normalize(i.worldNormal))), _PowerGlow);
                texColor.rgb += _BaseColor.rgb * fresnel;

                // Intersection glow
                float sceneDepth = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE_PROJ(_CameraDepthTexture, UNITY_PROJ_COORD(i.screenPos)));
                float thisDepth = LinearEyeDepth(i.screenPos.z / i.screenPos.w);
                float depthDiff = saturate((sceneDepth - thisDepth) / _IntersectionDepth);
                texColor.rgb += _BaseColor.rgb * depthDiff;

                // Alpha affected by fresnel
                texColor.a = _Alpha * fresnel;

                return texColor;
            }
            ENDCG
        }
    }
}