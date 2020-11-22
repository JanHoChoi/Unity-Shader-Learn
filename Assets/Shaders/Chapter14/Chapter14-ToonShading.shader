Shader "Unity Shaders Book/Chapter 14/Toon Shading"
{
    Properties
    {
        _Color ("Color Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Main Tex", 2D) = "white" {}
        _Ramp ("Ramp Texture", 2D) = "white" {}
        _Outline ("Outline", Range(0, 1)) = 0.1
        _OutlineColor ("Outline Color", Color) = (1, 1, 1, 1)
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _SpecularScale ("Specular Scale", Range(0, 0.1)) = 0.01
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry"}
        Pass
        {
            NAME "OUTLINE"

            Cull Front // 只渲染背面

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float _Outline;
            fixed4 _OutlineColor;
            
            struct a2v
            {
                float3 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            v2f vert (a2v v)
            {
                v2f o;

                float4 pos = float4(UnityObjectToViewPos(v.vertex), 1.0);
                float3 normal = mul((float3x3)UNITY_MATRIX_IT_MV, v.normal); // 把法线转换到视觉view空间
                normal.z = -0.5;
                pos = pos + float4(normalize(normal), 0) * _Outline;
                o.pos = mul(UNITY_MATRIX_P, pos);
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                return float4(_OutlineColor.rgb, 1);
            }

            ENDCG
        }

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            Cull Back

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "autolight.cginc"
            #include "lighting.cginc"

            fixed4 _Color;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Ramp;
            float _Outline;
            fixed4 _OutlineColor;
            fixed4 _Specular;
            float _SpecularScale;

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
                float4 worldPos : TEXCOORD2;
                SHADOW_COORDS(3)
            };

            v2f vert(a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                TRANSFER_SHADOW(o);

                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(WorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir = normalize(WorldSpaceViewDir(i.worldPos));
                fixed3 worldHalfDir = normalize(worldLightDir + worldViewDir);

                fixed4 color = tex2D(_MainTex, i.uv);
                fixed3 albedo = color.rgb * _Color.rgb;  // 无光贴图
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;  // 环境光

                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);

                fixed diff = dot(worldNormal, worldLightDir);  // 漫反射
                diff = (diff * 0.5 + 0.5) * atten;
                fixed3 diffuse = _LightColor0.rgb * albedo * tex2D(_Ramp, float2(diff, diff)).rgb; // ramp贴图改变漫反射系数

                fixed spec = dot(worldNormal, worldHalfDir);  // 高光反射specular
                fixed w = fwidth(spec) * 2.0;
                fixed3 specular = _Specular.rgb * lerp(0, 1, smoothstep(-w, w, spec + _SpecularScale - 1)) * step(0.0001, _SpecularScale);

                return fixed4(ambient + diffuse + specular, 1.0);
                
            }

            ENDCG
        }
    }
    Fallback "Diffuse"
}
