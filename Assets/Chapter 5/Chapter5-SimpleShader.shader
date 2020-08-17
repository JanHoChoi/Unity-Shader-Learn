Shader "Unity Shaders Book/Chapter 5/Simple Shader"{
    SubShader{
        Pass{
            CGPROGRAM

            #pragma vertex vert     // vert函数名 表示该函数包含顶点着色器代码

            #pragma fragment frag   // frag函数名

            struct a2v{
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };

            float4 vert(a2v v) : SV_POSITION{
                return UnityObjectToClipPos(v.vertex); /* Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)' */
            }

            fixed4 frag() : SV_Target{
                return fixed4(1.0, 1.0, 1.0, 1.0);
            }

            ENDCG
        }
    }
}